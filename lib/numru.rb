require "numru/version"

# module Numru
#   # Your code goes here...
# end


require 'rubypython'

RubyPython.start


class NumRu
  @@np = RubyPython.import 'numpy'
  @@blt = RubyPython::PyMainClass.send(:new)
  
  attr_accessor :np_obj
  
  def initialize np_obj
    @np_obj = np_obj
  end

  def [](*args)
    args.map! do |i|
      case i
      when Range
        @@blt.slice(i.begin, i.end)
      else
        [i]
      end
    end
    args = args.map { |i| "ObjectSpace._id2ref(#{i.object_id})"}.join ','
    # p "@np_obj.__getitem__([#{args.join ','}])"
    NumRu.new eval("@np_obj.__getitem__([#{args}])")
  end
  
  def self.arg_to_s arg
    case arg
    when Hash
      return arg.map { |k, v| "#{k}=#{v.inspect}" }
    when NumRu
      return "ObjectSpace._id2ref(#{arg.object_id}).np_obj"
    end
    arg.to_s
  end
  
  def method_missing(m, *args)
    # p m, args
    args = args.map { |i| NumRu.arg_to_s i }.join ','
    # p "@np_obj.#{m}(#{args})"
    NumRu.new eval("@np_obj.#{m}(#{args})")
  end  
  
  def self.method_missing(m, *args)
    # p m
    args = args.map { |i| self.arg_to_s i }.join ','
    # p "@@np.#{m}(#{args})"
    NumRu.new eval("@@np.#{m}(#{args})")
  end
  
  def to_s
    @np_obj
  end
  
  def inspect
    to_s
  end
end
