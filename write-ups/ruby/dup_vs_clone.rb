RSpec.configure do |config|
  config.default_formatter = "doc"
  config.alias_example_to :they
end

RSpec.describe "dup vs. clone" do
  they "both create shallow copies" do
    arr = %w[an array of strings]

    dup_arr = arr.dup
    clone_arr = arr.clone

    expect(dup_arr.object_id).not_to eq arr.object_id
    expect(clone_arr.object_id).not_to eq arr.object_id

    arr_object_ids = arr.map(&:object_id)

    # the objects inside the array are not copied, only their references.
    expect(dup_arr.map(&:object_id)).to contain_exactly(*arr_object_ids)
    expect(clone_arr.map(&:object_id)).to contain_exactly(*arr_object_ids)
  end

  describe "dup" do
    context "copies without special attributes" do
      it "ignores freezed status" do
        str = "some constant string".freeze
        dup_str = str.dup

        expect(str).to be_frozen
        expect(dup_str).not_to be_frozen
      end

      it "ignores tainted status" do
        skip "can't find a way to create a tainted object"

        # Objects created from external sources are marked as tainted.
        # Any object derived from this object is marked as tainted.
        obj = ENV["GEM_HOME"]

        dup_obj = obj.dup

        expect(obj).to be_tainted
        expect(dup_obj).not_to be_tainted
      end

      it "ignores singleton class" do
        obj = %w[some kind of object]
        def obj.method_in_singleton_class
          # this method goes to obj's singleton class.
        end

        dup_obj = obj.dup
        expect(obj).to respond_to(:method_in_singleton_class)
        expect(dup_obj).not_to respond_to(:method_in_singleton_class)
      end
    end
  end

  describe "clone" do
    context "copies the object as it is (including special attributes)" do
      it "copies freezed status" do
        str = "some constant string".freeze
        clone_str = str.clone

        expect(str).to be_frozen
        expect(clone_str).to be_frozen
      end

      it "copies tainted status" do
        skip "can't find a way to create a tainted object"

        # Objects created from external sources are marked as tainted.
        # Any object derived from this object is marked as tainted.
        obj = ENV["GEM_HOME"]

        clone_obj = obj.clone

        expect(obj).to be_tainted
        expect(clone_obj).not_to be_tainted
      end

      it "copies singleton class" do
        obj = %w[some kind of object]
        def obj.method_in_singleton_class
          # this method goes to obj's singleton class.
        end

        clone_obj = obj.clone
        expect(obj).to respond_to(:method_in_singleton_class)
        expect(clone_obj).to respond_to(:method_in_singleton_class)
      end
    end
  end
end