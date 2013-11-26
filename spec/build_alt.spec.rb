
require 'wires'
require 'wires/test'

require 'spec_helper'


module UserModule
  Wires::Util.build_alt "::#{self}::AltWires"
  Wires::Test.build_alt "::#{self}::AltWires", affix:'alt'
  AltWires.extend AltWires::Convenience
end

describe Wires::Test do
  
  describe ".build_alt" do
    
    it "builds an alternate version of the Wires::Test module" do
      expect(Wires::Test)        .not_to eq ::UserModule::AltWires::Test
      expect(Wires::Test::Helper).not_to eq ::UserModule::AltWires::Test::Helper
    end
    
    it "replaces the instance methods of Wires::Test::Helper" do
      mod     =                  Wires::Test::Helper
      alt_mod = ::UserModule::AltWires::Test::Helper
      alt_obj = Object.new.extend alt_mod
      mod.instance_methods(false).each_with_index do |sym,i|
        expect(alt_obj).not_to respond_to sym
        expect(sym).to eq alt_mod.instance_methods(false)[i].to_s
                                 .gsub(/alt_/,'').to_sym
      end
    end
    
    it "replaces the instance variables of Wires::Test::Helper" do
      obj     = Object.new.extend                  Wires::Test::Helper
      alt_obj = Object.new.extend ::UserModule::AltWires::Test::Helper
      
      obj        .wires_test_setup
      alt_obj.alt_wires_test_setup
      
      obj.instance_variables.each_with_index do |sym, i|
        expect(alt_obj.instance_variables).not_to include sym
        expect(sym).to eq alt_obj.instance_variables[i].to_s
                                 .gsub(/alt_/,'').to_sym
      end
    end
    
    it "replaces the instance methods of Wires::Test::RSpec::ExampleGroupMethods" do
      mod     =                  Wires::Test::RSpec::ExampleGroupMethods
      alt_mod = ::UserModule::AltWires::Test::RSpec::ExampleGroupMethods
      alt_obj = Object.new.extend alt_mod
      mod.instance_methods(false).each_with_index do |sym,i|
        expect(alt_obj).not_to respond_to sym
        expect(sym).to eq alt_mod.instance_methods(false)[i].to_s
                                 .gsub(/alt_/,'').to_sym
      end
    end
    
#     it "can assign an affix to all defined methods of Helper" do
#       [:clear_fired,  :fired?, 
#        :assert_fired, :refute_fired].each do |x|
#         UserModule::AltWires::Test::Helper.instance_methods.wont_include x
#       end
#       [:clear_alt_fired,  :alt_fired?, 
#        :assert_alt_fired, :refute_alt_fired].each do |x|
#         UserModule::AltWires::Test::Helper.instance_methods.must_include x
#       end
#     end
    
#     describe "crosstalk" do
#       include Wires::Convenience
#       include Wires::Test::Helper
#       include UserModule::AltWires::Test::Helper
      
#       it "doesn't crosstalk when events are fired" do
        
#         fire             :event, 'channel'
        
#         assert_fired     :event, 'channel'
#         refute_alt_fired :event, 'channel'
        
#         clear_fired
#         clear_alt_fired
        
#         UserModule::AltWires.fire :event, 'channel'
        
#         refute_fired     :event, 'channel'
#         assert_alt_fired :event, 'channel'
        
#         clear_fired
#         clear_alt_fired
        
#       end
#     end
    
  end
  
end
