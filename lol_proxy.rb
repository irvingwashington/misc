class LolProxy < BasicObject 
  def initialize(obj)
    @obj=obj 
  end 

  def method_missing(*args) 
    val = @obj.send(*args)
      ::IO::STDOUT.puts("Method call: #{args[0]}, caller: #{::Kernel.caller.slice(0,2).join(', ')}, val: #{val.inspect}")
    val
  end

end

