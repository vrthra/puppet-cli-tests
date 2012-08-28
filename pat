#!/usr/bin/ruby
require 'rubygems'
require 'colorize'
module Patlog
  #=======debug==========
  #showbt
  $gopt ||= {}
  #=======debug==========
  class Log
    def useopt(options)
      @options = options
    end
    def out(arg)
      if $gopt['showxchars']
        p arg
      else
        puts arg
      end
    end
    def o(arg)
      puts arg
    end
    def v(num)
      return true if @options.verbose > num
    end
    def cr(cr)
      out (":\t##{cr}").cyan if v(0)
    end
    def title(title)
      out (":\t#{title}" ).yellow
    end
    def show(info)
      out info
    end
    def pending(info)
      out ("pending: #{pending}").cyan
    end
    def cause(arg)
      out ("Cause: " + arg).red
    end
    def fail(fail)
      out ("Error: " + fail).red
    end
    def error(fail)
      out ("Fatal: " + fail).red
    end
    def info(info)
      out info if v(1)
    end
    def verbose(info)
      out info if v(10)
    end
    def bt(err)
      if $gopt['showbt']
        out err.backtrace.join("\n")
      end
    end
    def dmatch(str)
      if $gopt['showdelimmatch']
        out "(#{str})"
      end
    end
    def matchlines(str)
      if $gopt['showmatch']
        out str
      end
    end
    def debug(str)
      if $gopt['showdebug']
        out str
      end
    end
    def response(data)
      if $gopt['showdebug'] && !data.nil?
        data.each {|str|
          out "#{str.chomp.cyan}"
        }
      end
    end
    def request(data)
      if $gopt['showdebug'] && !data.nil?
        data.each {|str|
          out "| #{str}"
        }
      end
    end
    def die(info, exit_code)
      out info
      exit exit_code
    end
    def showtime(t)
      out "Time taken: #{t} seconds" if $gopt['showtime']
    end
  end

  class StdoutLog < Log
  end
end
module Pat
require 'timeout'
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'
module MatchWorld
  #===================Match world=====================
  class Match
    def initialize(opt, store)
      @store = store
      @log = store.log
      match = {}
      class << match
        def [](*args)
          key = args.shift
          if include? key
            s = fetch(key)
            return s[0] if args.empty?
            num = args.shift
            val = s[1][num]
            raise "Matches does not contain group #{num} for (#{key}). possible groups [#{s.length}]" if val.nil?
            return val
          else
            raise "Matches does not contain (#{key}). possible [#{keys.join(',')}]"
          end
        end
      end
      Thread.current['matches'] = match
      if opt.keys.collect{|x|x.to_s}.include?('seq')
        @delegate = SeqMatch.new(opt, MatchLine.new(store), store)
      else
        @delegate = FullMatch.new(opt, MatchLine.new(store), store)
      end
    end
    def compare(exp, data)
      return @delegate.compare(exp,data)
    end
  end

  class SeqMatch
    def initialize(opt, linematcher, store)
      @strict = opt.keys.collect{|x|x.to_s}.include?('strict')
      @linematcher = linematcher
      @log = store.log
    end
    def compare(exp, data)
      expidx = 0
      dataidx = 0
      while true
        curexp = exp[expidx]
        curdata = data[dataidx]
        if @linematcher.compare(curexp, curdata)
          expidx += 1
          dataidx += 1
          return true if expidx == exp.length
          next
        else
          if @strict
            raise "[#{curexp}] != [#{curdata}]"
          end
          dataidx += 1
          if dataidx == data.length
            raise curexp
            return false
          end
          next
        end
      end
      return true
    end
  end

  class FullMatch

    def initialize(opt, linematcher, store)
      @linematcher = linematcher
      @log = store.log
    end

    def compare(exp, data)
      exp.each do |curexp|
        curexp.chomp!
        @log.info("exp: #{curexp}")
        found = false
        data.each do |curdata|
          curdata.chomp!
          if @linematcher.compare(curexp, curdata)
            found = true
            break
          end
        end
        if !found
          raise curexp
        end
      end
      return true
    end
  end

  class TreeMatch
    #dummy for xml matching
    def compare(exp, data)
      return true
    end
  end

  #-----------------------------------------
  class MatchLine
    def initialize(store)
      @log = store.log
    end
    def compare(exp, data)
      @log.matchlines "[#{exp}] <> [#{data}]"
      #find the type of exp
      return true if exp.nil?
      case exp.chomp
      when /^[ \t]*\/(.*)\//
        return false if data.nil?
        val = regex_compare($1, data.chomp)
        if val
          Thread.current['matches'][$1] = [data.chomp,val]
          return true
        end
      when /^[ \t]*\?(.*)\?/
        return true if data.nil?
        val = regex_compare($1, data.chomp)
        if !val
          Thread.current['matches'][$1] = [data.chomp,nil]
          return true
        end
      when /^[ \t]*#.*/
        return true
      else
        return false if data.nil?
        val = ((exp.chomp <=> data.chomp) == 0)
        Thread.current['matches'][exp] = [data,nil] if val
        return val
      end
    end

    def regex_compare(exp,data)
      return Regexp.new(exp).match(data)
    end
  end

end
module Connectors
  require 'pathname'
  #==================================
  class Conn
    def initialize()
      @opt = {}
    end

    def opt(opt)
      @opt = opt if !opt.nil?
    end

    def port(port=nil)
      @port = port if !port.nil?
      return @port
    end

    def <<(data)
      socket() << data
    end

    def closed?
      return true if socket().closed?
    end

    def readlines
      lines = []
      while !eof?
        line = readline
        if block_given?
          yield line
        else
          lines << line
        end
      end
      return lines unless block_given?
    end

    def write(data)
      self << data
    end

    def readchar()
      return socket().readchar
    end

    def machine
      return "#{self}"
    end

    def split_host_port(hp, def_port)
      host = hp
      port = def_port
      case hp
      when /^([^:]+):([0-9]+)$/
        host = $1
        port = $2.to_i
      end
      return [host, port]
    end

    def >>
      return readline()
    end

    def eof?
      return socket().eof?
    end

    def readline
      return socket().readline
    end

    def close
      socket().close
    end
  end

  class ClientConn < Conn
    def initialize(host_port)
      @host, @port  = split_host_port(host_port,80)
      @sock = nil
    end
    def machine
      return "#{@host}:#{@port}"
    end

    def opt(opt)
      @opt = opt if !opt.nil?
    end

    def <<(data)
      if @opt.nil? || !@opt.include?("nocrlf")
        d = data.split(/\Z/).collect {|l|l.chomp().sub(/\Z/,"\r\n")}
        socket() << d.join("")
      else
        socket() << data
      end
    end

    def socket
      if @sock.nil?
        @sock =  TCPSocket.open(@host, @port)
      end
      return @sock
    end
    def close
      @sock.close unless @sock.nil? or @sock.closed?
    end

    def closed?
      return true if @sock.nil? || @sock.closed?
    end
  end

  #==============================================
  #exclusive console stuff
  #ConsoleClientConn for writing to args
  #ConsoleOutClientConn for writing to stdout
  #it can be upgraded in the middle like Connect
  #==============================================
  class ConsoleClientConn < Conn
    def initialize()
      @cmd = nil
    end

    def socket
      return @cmd
    end

    def close
      if !@cmd.nil?
        @cmd.close if !@cmd.closed?
        @exitval = ($? >> 8)
        @cmd = nil
        raise "Command #{@cmdstr} failed (#{@exitval})." if @exitval > 0
      end
      @cmdstr = nil
    end

    def readline
      return @cmd.gets
    end

    def <<(cmd)
      @cmdstr = cmd.chomp
      @cmd = open("|#{@cmdstr}")
    end

    def >>
      return readline;
    end

    def eof?
      return true if @cmd.nil? or @cmd.eof?
    end
  end

  class XCli < ConsoleClientConn
    def <<(cmd)
      @cmdstr = cmd
      @cmd = `#{@cmdstr.chomp}`.split("\n")
    end

    def readlines
      @cmd
    end
    def readline
      @cmd.shift
    end

    def eof?
      @cmd.nil? || @cmd.empty?
    end

    def close
      return unless @cmdstr
      @cmd = nil
      @cmdstr = nil
    end
  end

  class PuppetEnv < ConsoleClientConn
    def <<(cmd)
      @cmd = open("|./ext/envpuppet #{cmd}")
    end
  end

  class PuppetCli < ConsoleClientConn
    def <<(cmd)
      @cmdstr = cmd.chomp
      case @cmdstr
      when /\s*(\S+) (.+)/
        @cmd = open("|./ext/envpuppet puppet #{$1} --color=false #{$2} 2>&1")
      end
    end
  end

  class PkgCmd < ConsoleClientConn
    #export PKG_TRANS_ID=1346076290_pkg%3A%2F%2FPuppet%2Fpuppet%403.0.0%2C5.11%3A20120827T140450Z
    def initialize(url, pkg)
      puts "< pkgsend -s #{url} open #{pkg}"
      s = `pkgsend -s #{url} open #{pkg}`
      case s
      when /export ([^= ]+)=([^ ]+)/
        @k=$1
        @v=$2.chomp
        puts "> #{@v}"
      else
        raise "Unknown #{s}"
      end
    end

    def <<(cmd)
      @cmdstr = cmd.chomp
      ENV['PKG_TRANS_ID'] = @v
      @cmd = `#{@cmdstr}`.split("\n")
    end

    def readline
      @cmd.shift
    end

    def eof?
      @cmd.nil? || @cmd.empty?
    end

    def readlines
      @cmd
    end

    def close
      return unless @cmdstr
      puts "> pkgsend -s http://localhost close"
      ENV['PKG_TRANS_ID'] = @v
      s = `pkgsend -s http://localhost close`
      puts "< #{s}"
      @cmd = nil
      @cmdstr = nil
    end
  end

  class CatFile < ConsoleClientConn
    def <<(file)
      @cmdstr = file
      @cmd = open(@cmdstr)
    end
  end

  class FileConn < ConsoleClientConn
    def initialize(file, type='a')
      @file = File.open(file, type)
    end
    def close()
      @file.close if !@file.nil?
    end
    def <<(str)
      @file << str
    end
    def socket
      return @file
    end
    def >>
      return readline();
    end
    def readline()
      return @file.gets
    end
    def eof?
      return @file.eof?
    end
  end
end
module Transform
  class TabTrans
    def initialize(proxy)
      @proxy = proxy
    end
    def transform(data)
      data.collect! {|l|l.gsub(/\t/,@proxy)} if !data.nil?
    end
  end
  class CaseTrans
    def transform(data)
      data.collect! {|l|l.downcase} if !data.nil?
    end
  end
  class PrintTrans
    def transform(data)
      data.collect! {|l|l.dump} if !data.nil?
    end
  end
  class SqueezeTrans
    def transform(data)
      data.collect! {|l|l.squeeze(" ")} if !data.nil?
    end
  end
  class TrimTrans
    def transform(data)
      data.collect! {|l|l.strip} if !data.nil?
    end
  end
  class ChopTrans
    def transform(data)
      data.collect! {|l|l.chop} if !data.nil?
    end
  end
end

include MatchWorld
include Connectors
include Transform
include Patlog


DAY = 60*60*24
$active_connections = []

#==============================================
class Chunk
  def initialize()
    @lines = []
    @source = []
  end
  def <(str)
    @lines << str
    return self
  end
end

class Req < Chunk
  #I need macros *NOW*

  def initialize(opt)
    @lines = []
    @source = []
    @opt = opt
  end

  def compile()
    @source << %Q(
#=======<receive>)
    @source <<%Q[
    #=========================
    @expstr = <<__DATA
#{@lines}__DATA
    @exp = @expstr.split($/)
    @opt = {#{@opt}}
    @connection.opt(@opt)
    if @cdata.empty?
        read_all()
    end
    log_request @cdata
    #=========================
    @transforms = @restrans.clone
    transform(@exp, @opt)
    transform(@cdata, @opt)
    if try_match(@opt)
        match_txt(@exp, @cdata, @opt)
        @cdata.clear
    end
    ]

    @source << %Q(
#=======</receive>)
    return @source
  end
end

class Res < Chunk

  def initialize(opt)
    @lines = []
    @source = []
    @opt = opt
  end

  def compile
    @source << %Q(
#=======<send>)
    response = @lines.join()
    @source <<%Q[
    @cdata.clear
    @sdata =<<__DATA
#{response}__DATA
    @opt = {#{@opt}}
    @connection.opt(@opt)
    #we dont really want to touch the data
    #other than defined transforms so not splitting it.
    data = Array.new(1,@sdata)
    @transforms = {}
    transform(data,@opt)
    @sdata = data.shift
    @connection << @sdata
    log_response @sdata
#=======</send>]
      return @source
  end
end

# Executable Ruby statements
class Eval < Chunk
  def compile
    @source << %Q(
#=======<eval>)
    @source << %Q(
#{@lines}
#=======</eval>)
    return @source
  end
end

class EConf < Chunk
  def compile
    @source << %Q(
#=======<econf>)
    @source << %Q(
#{@lines}
#=======</econf>
    )
    return @source
  end
end

class Conf < Chunk
  def initialize(base='')
    @base = base
    super()
  end
  def process(line)
    test = line[/[^\[]+/]
      if line =~ /\[([^\]]+)\]/
        test << $1
      end
      return test
  end
  def compile
    @seq = []
    @lines.each do |l|
      line = l.chomp.rstrip.lstrip
      next if line.empty?
      if  line =~ /^[ \t]*#.*$/
        @source << "#runtest '#{@base + process(line)}'"
      else
        @source << "runtest '#{@base + process(line)}'"
      end
    end
    return @source
  end
end

class ConnProxy
  def initialize(conn)
    @connections = [conn]
  end

  def method_missing(method,*args)
    @connections.last.send(method,*args)
  end

  def <<(data)
    @connections.last << data
  end

  def opt(opt)
    @connections.last.opt(opt)
  end

  def <(conn)
    @connections << conn
  end
  def <(conn)
    @connections << conn
  end

  def close
    @connections.pop.close
  end
  def current()
    @connections.last
  end

  def destroy
    @connections.each {|conn|
      conn.close if !conn.closed?
    }
    @connections = []
  end
end

#the holder for executing test cases.
class PatObject
  def initialize(file, conn, store)
    @file = file
    @connection = ConnProxy.new(conn)
    @store = store
    @log = store.log
    @options = store.options

    class << @options
      def [](arg)
        pairs[arg]
      end
    end


    @restrans = {
      'tabs' => Transform::TabTrans.new(' '),
      'case' => Transform::CaseTrans.new(),
      'trim' => Transform::TrimTrans.new(),
    }

    #allow setting of matcher from test cases
    @matcher = nil

    #data from socket
    @cdata = []

    #the assert language data
    @sdata = ""
  end

  def conn
    return @connection.current
  end

  def opt
    return @options
  end

  #use take :Name , args
  def take(name,*args)
    @connection < name.new(*args)
    $active_connections << @connection.current
    if block_given?
      yield @connection.current
      drop
    end
  end

  def drop
    @connection.close
  end

  def include(arg)
    PatObject.module_eval "include #{arg}"
  end

  def match_txt(exp, data, opt)
    #allow setting of matcher from test cases
    @matcher = Match.new(opt,@store) if @matcher.nil?
    val = @matcher.compare(exp,data)
    @matcher = nil
    return val
  end

  def transform(arr, opts)
    opts.keys.each do |opt|
      case opt.to_s
      when /^[c]ase$/; @transforms.delete('case')
      when /^tabs$/; @transforms['tabs'] = TabTrans.new(opts['tabs'])
      when /^notrim$/; @transforms.delete('trim')
      when /^chop$/; @transforms['chop'] = ChopTrans.new()
      end
    end
    @transforms.keys.each do |trans|
      @transforms[trans].transform(arr)
    end
  end

  def readtill(*rest)
    hash = rest.first
    hash ||={}
    exp = hash[:exp]
    len = hash[:len]
    @cdata = [read_till(exp,len)]
  end
  def read_till(exp,len)
    data = ""
    l = 0
    begin
      while data << @connection.socket().readchar
        l+=1
        if !exp.nil? and
          ((exp.instance_of?(Regexp) and (data =~ exp)) or
           (exp.instance_of?(String) and data.include?(exp)))
           break
        end
        if !len.nil? and l >= len
          break
        end
        break if @connection.eof?
      end
      @log.dmatch "matched:#{data} == #{exp}"
      return data
    rescue Exception => e
      carp e.message
      @log.bt e
      return data
    end
  end

  def read_all()
    reply = []
    exp = []
    maxlen = nil
    till = nil
    aexp = @opt[:$line]
    if !aexp.nil?
      if !aexp.instance_of?(Array)
        exp << aexp
      else
        exp = aexp
      end
    end
    till = @opt[:$till]
    maxlen = @opt[:$len]
    if !till.nil? or !maxlen.nil?
      data = read_till(till, maxlen)
      @cdata = data.split(/\n/)
      return
    end
    until @connection.eof?
      line = @connection.readline
      reply << line
      #loop until we match all the delimiters.
      match = 0
      @log.dmatch "#{line}" if exp.length == 0
      exp.each {|e|
        if (e.instance_of?(Regexp) and (line =~ e)) or
          (e.instance_of?(String) and (line == e))
          match += 1
          @log.dmatch "#{line} == #{e.to_s.dump}"
        else
          @log.dmatch "#{line} <> #{e.to_s.dump}"
        end
      }
      if match != 0 && match == exp.length
        @cdata = reply.compact
        return
      end
    end
    @cdata = reply.compact
  end
  def try_match(opt)
    exp = opt[:when?]
    return true if exp.nil?
    case exp.class.to_s
    when /Regexp/
      return true if @cdata.grep( exp ).length > 0
    when /String/
      return true if @cdata.include?(exp)
    when /Proc/
      case exp.arity
      when 1
        return true if !@cdata.find(exp).nil?
        #            when 0 #Hack warning :) allow instance variables like @cdata to be accessed from the exp.
        #                return true if eval(exp, self.binding)
      end
    end
    return false
    end
  def matches
    return Thread.current['matches']
  end

  def execute(myfile)
    self.instance_eval myfile, @file
  rescue Exception => e
    @log.cause "#{@file} [#{e.message()}]"
    @log.bt e
    return false
  ensure
    begin
      @connection.destroy
    rescue;end
  end

  def use(tc)
    p = Pathname.new(tc)
    #todo - place a libname in between.
    tcase = p.dirname.to_s + '/' + p.basename.to_s
    parser = Parser.create(tcase, @store)
    if !parser.nil?
      myfile = parser.getsrc()
      self.instance_eval myfile, tc
    end
  end
  #====================================
  #loggging
  def cr(cr)
    @log.cr cr
  end
  def title(title)
    @log.title title
  end
  def info(info)
    @log.info info
  end
  def show(info)
    @log.show info
  end
  def pending(info)
    @log.pending info
  end
  def log_request(data)
    @log.request(data)
  end
  def log_response(data)
    @log.response(data)
  end
  def client_data(arr)
    @cdata = arr if  !arr.nil? && !arr.empty?
  end
end


class Parser
  def initialize(file, store, txt)
    @file = file
    @src = []
    @store = store
    @log = store.log
    @test_objects = compile(txt,Eval.new)
  end
  def self.create(file,store)
    txt = store.io.getlines(file + '.pat')
    return nil if txt.nil?
    return Parser.new(file, store, txt)
  end
  def compile(txt,obj)
    tc = []
    ob = false
    txt.each {|line|
      #switch based on the line start
      case line
      when /^ *<\[(.*)$/  #outgoing request
        tc << obj
        obj = Req.new($1)
        ob = true
      when /^ *>\[(.*)/  #incoming request
        tc << obj
        obj = Res.new($1)
        ob = true
      when /^ *\] *$/  #end re(q|s)
        if ob
          tc << obj
          obj = Eval.new()
          ob = false
        end
      else
        obj<line
      end
    }
    tc << obj
    return tc
  end

  def process
    if !@store.options.usedump
      @test_objects.each {|obj|
        @src << obj.compile
      }
    end
    return true
  end

  def getsrc()
    process()
    if !@store.options.usedump
      myfile = @src.join "\n"
      myfile += "\nreturn true"
      myfile.gsub!(/%remove%/,"")
      if @store.options.dump
        File.open("#{@file}.pat.rb",'w') {|f|
          f << myfile
        }
      end
    else
      myfile = File.open("#{@file}.pat.rb",'r').read
    end
    return myfile
  end
end
#=====================================================
class PatClient
  def initialize(store)
    @host_port = store.options.proxy_host_port
    @store = store
    @log = store.log
  end
  def run(tcase)
    parser = Parser.create(tcase, @store)
    if !parser.nil?
      conn = Connectors::ClientConn.new(@host_port)
      myfile = parser.getsrc()
      @patobj = PatObject.new(tcase, conn, @store)
      if @patobj.execute(myfile)
        @log.show "#{tcase} successfully completed"
      else
        $failed += 1
        @log.show "#{tcase} failed"
      end
    else
      @log.error "TestCase #{tcase}.pat does not exist"
    end
  rescue Exception => e
    @log.error "#{e.message()} (#{@host_port})"
    @log.bt e
  end
end

class StdIO
  def getlines(file)
    begin
      return File.open(file).readlines
    rescue
      return nil
    end
  end
end

class PatStore
  def initialize(log=nil,io=nil)
    if log.nil?
      @log = StdoutLog.new
    else
      @log = log
    end
    if io.nil?
      @io = StdIO.new
    else
      @io = io
    end
    at_exit do
      $active_connections.each do |conn|
        begin
          conn.close if conn
        rescue
        end
      end
    end
  end
  def io
    return @io
  end
  def parse_opt(args)
    @opt = OptRun.parse(args, @log)
    @log.useopt @opt
    @log.verbose "seq:#{@opt.seq} proxy:#{@opt.proxy_host_port} server:#{@opt.server_host}:#{@opt.server_port}"
  end
  def set_opt(arg)
    @opt = arg
  end
  def log
    return @log
  end
  def options
    return @opt
  end
  def seq
    return @opt.seq
  end
end

class Seq
  def initialize(store)
    $failed = 0
    @store = store
    @log = store.log
    @pc = PatClient.new @store
    tc = []
    time = Time.now
    if @store.seq =~ /\.seq$/
      #should we allow *.pat from http://index list ??
      use(@store.seq.sub(/\.seq$/,''))
    else
      txt = Dir[@store.seq]
      if txt.length != 0
        tc += compile('',txt.grep(/(.+)\.pat/).collect{|l| l.sub(/\.pat$/,'')}, Conf.new)
      else
        if @store.seq =~ /\.pat$/
          tc += compile('',@store.seq.sub(/\.pat$/,''), Conf.new)
        end
      end
      process(@store.seq,tc)
    end
    @log.show("Failure: #{$failed}") if $failed > 0
    @log.showtime(Time.now - time)
  end

  def use(seq)
    txt = @store.io.getlines(seq + '.seq')
    return if txt.nil?
    dn = File.dirname(seq + '.seq') + '/'
    tc = compile(dn, txt, EConf.new)
    process(seq + '.seq',tc)
  end

  def compile(base, txt,obj)
    tc = []
    txt.each {|line|
      #switch based on the line start
      case line
      when /^ *\[/  #start of seq
        tc << obj
        obj = Conf.new(base)
      when /^ *\] *$/  #end seq
        tc << obj
        obj = EConf.new()
        #when /^[ \t]*#.*$/  #comments
        #nothing
      else
        obj<line
      end
    }
    tc << obj
    return tc
  end

  def process(seq,tc)
    if !@store.options.usedump
      src = []
      tc.each {|t|
        src << t.compile
      }
      s = src.join("\n")
      #----------XXX
      puts s if $debug_seq
      #----------XXX
      if @store.options.dump
        File.open(seq + '.rb', 'w') {|f|
          f << s
        }
      end
    else
      s = File.open(seq + '.rb','r').read
    end
    self.instance_eval s, seq
  end

  def has(grp)
    negate = false
    return true if @store.options.groups.empty?
    @store.options.groups.each do |opt|
      if opt[-1].chr == '-'
        negate = true
        return false if opt.chop.eql? grp
      else
        return true if opt.eql? grp
      end
    end
    return true if negate
    return false
  end


  def runtest(conf)
    @log.verbose "processing testcase #{conf}"
    arr = conf.split(/[ \t]+/)
    file = arr.shift
    if !arr.empty?
      arr.delete_if {|x| !has(x)}
      return false if arr.empty?
    end

    @pc.run file
  end
end

class OptRun
  def self.parse(args, log)
    @log = log
    @continue = true
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new

    options.seq = 'pat.seq'
    options.verbose = 0
    options.dump = false
    options.usedump = false
    options.timeout = DAY
    options.groups = []

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: pat.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-s", "--seq=sequence", "The sequence of testcases") do |seq|
        options.seq = seq
      end

      opts.on("-t", "--timeout=timeout", "The max timeout in seconds") do |t|
        options.timeout = t.to_i
      end

      opts.on("-v", "--verbose=verbose", "Run verbosely [1..]") do |v|
        options.verbose = v.to_i
      end

      opts.on("-d", "--[no-]dump", "dump evaluation") do |d|
        options.dump = d
      end

      opts.on("-u", "--usedump", "use earlier dumps") do |u|
        options.usedump = u
      end

      opts.on("-x", "--ext a b c", Array, "use bt-backtrace|delim-dumpdelimmatch|time|xchars|match|debug") do |e|
        options.extended = e
        $gopt ||= {}
        e.each do |opt|
          case opt.strip
          when /^bt$/
            $gopt['showbt'] = true
          when /^delim$/
            $gopt['showdelimmatch'] = true
          when /^debug$/
            $gopt['showdebug'] = true
          when /^time$/
            $gopt['showtime'] = true
          when /^xchars$/
            $gopt['showxchars'] = true
          when /^match$/
            $gopt['showmatch'] = true
          end
        end
      end

      opts.on_tail("-g", "--groups x y z", Array,  "selected groups") do |g|
        options.groups = g
      end

      opts.separator ""
      opts.separator "Common options:"

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("-h", "--help", "Show this message") do
        @log.show opts
        exit
      end

      opts.on_tail("--version", "Show version") do
        @log.show '0.9'
        exit
      end
    end

    opts.parse!(args)
    options.pairs = {}
    options.remaining = []
    args.each {|arg|
      #check if they contain '='
      if arg =~ /^(.+)=(.+)$/
        options.pairs[$1] = $2
      else
        options.remaining << arg
      end
    }
    options
  end
end

end
include Pat

store = PatStore.new()
store.parse_opt(ARGV)
s = Seq.new store
