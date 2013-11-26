
# module UserModule
#   Wires::Util.build_alt "::#{self}::AltWires"
#   Wires::Test.build_alt "::#{self}::AltWires", affix:'alt'
#   AltWires.extend AltWires::Convenience
# end

# describe Wires::Test do
  
#   describe ".build_alt" do
    
#     it "builds an alternate version of the Wires::Test module" do
#       module UserModule
#         Wires::Test        .wont_equal AltWires::Test
#         Wires::Test::Helper.wont_equal AltWires::Test::Helper
#       end
#     end
    
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
    
#   end
  
# end
