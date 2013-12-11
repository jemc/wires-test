

shared_examples "a module transformed by build_alt" do
  it "it gets its instance methods replaced" do
    alt_obj = Object.new.extend alt_mod
    mod.instance_methods(false).each_with_index do |sym,i|
      expect(alt_obj).not_to respond_to sym
      expect(sym).to eq alt_mod.instance_methods(false)[i].to_s
                               .gsub(/alt_/,'').to_sym
    end
  end
  
  it "it gets its instance variables replaced" do
    obj     = Object.new.extend mod
    alt_obj = Object.new.extend alt_mod
    
    begin; obj        .wires_test_setup; rescue NoMethodError; end
    begin; alt_obj.alt_wires_test_setup; rescue NoMethodError; end
    
    obj.instance_variables.each_with_index do |sym, i|
      expect(alt_obj.instance_variables).not_to include sym
      expect(sym).to eq alt_obj.instance_variables[i].to_s
                               .gsub(/alt_/,'').to_sym
    end
  end
end




def all_matchers
  RSpec::Matchers.instance_methods
end

def all_contexts
  RSpec::Core::SharedExampleGroup
    .shared_example_groups
    .instance_variable_get(:@examples)
    .values.map(&:keys)
    .flatten
end


# Save RSpec matcher and shared example lists before the build_alt
$pre_existing_matchers = all_matchers
$pre_existing_contexts = all_contexts

require 'wires'
require 'wires/test'

require 'spec_helper'

$defined_matchers = all_matchers - $pre_existing_matchers
$defined_contexts = all_contexts - $pre_existing_contexts



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
    
    describe Wires::Test::Helper do
      let(:mod)     {                  Wires::Test::Helper }
      let(:alt_mod) { ::UserModule::AltWires::Test::Helper }
      it_behaves_like "a module transformed by build_alt"
    end
    
    describe Wires::Test::RSpec::ExampleGroupMethods do
      let(:mod)     {                  Wires::Test::RSpec::ExampleGroupMethods }
      let(:alt_mod) { ::UserModule::AltWires::Test::RSpec::ExampleGroupMethods }
      it_behaves_like "a module transformed by build_alt"
    end
    
    it "copies and transforms the RSpec matchers that were defined" do
      ary = all_matchers - $pre_existing_matchers - $defined_matchers
      ary = ary.map(&:to_s).map{|s| s.gsub /alt_/, ''}.map(&:to_sym)
      expect(ary).to match_array $defined_matchers
    end
    
    it "copies and transforms the RSpec shared contexts that were defined" do
      ary = all_contexts - $pre_existing_contexts - $defined_contexts
      ary = ary.map(&:to_s).map{|s| s.gsub /alt_/, ''}.map(&:to_s)
      expect(ary).to match_array $defined_contexts
    end
    
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
