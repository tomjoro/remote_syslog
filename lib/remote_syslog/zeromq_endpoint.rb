module RemoteSyslog
  class ZeromqEndpoint
    def initialize(address, port, options = {})
      @address = address
      @port    = port.to_i
      connect
    end

    def resolve_address
      request = EventMachine::DnsResolver.resolve(@address)
      request.callback do |addrs|
        @cached_ip = addrs.first
      end
    end

    def address
      @cached_ip || @address
    end

    def connect
      @context = ZMQ::Context.new(1)
      @sender = @context.socket(ZMQ::PUSH)
      @sender.connect("tcp://#{@address}:#{@port}")
    end

    def write(value)
      if @sender
        @sender.send(value.to_s)
      end
    end
  end
end