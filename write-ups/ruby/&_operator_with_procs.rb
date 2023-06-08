RSpec.configure do |config|
  config.default_formatter = "doc"
end

RSpec.describe "'&' operator in the context of procs" do
  context "when applied to a symbol" do
    it "sends 'to_proc' to the symbol" do
      def some_method(&block)
        expect(block).to match a_kind_of Proc
      end

      some_method(&:each)
    end
  end

  context "when applied to a method's argument" do
    it "converts the block given to a Proc" do
      def some_method(&block)
        expect(block).to match a_kind_of Proc
      end

      some_method do
        # nothing
      end
    end
  end

  context "when applied to a Proc" do
    it "converts the Proc into a block" do
      def some_method
        yield
      end

      some_method(&lambda {})
    end
  end
end
