require 'spec_helper'

describe Memoized::Memoizer do
  let(:memoizer) { described_class.new(context, method) }

  let(:context) { klass.new }
  let(:klass) do
    output_value = value
    method_name = method

    Class.new do
      define_method(method_name) { |*_, &_| output_value }
    end
  end

  let(:method) { :american_exceptionalism }

  subject { memoizer.call(*args, &block) }

  shared_examples 'a memoized method' do |args, block, value|
    let(:args) { args }
    let(:block) { block }
    let(:value) { value }

    it 'caches the value' do
      is_expected.to eq value
      expect(memoizer.cache).to include([args, block] => value)
    end

    context 'and the subject has already run once' do
      before { memoizer.call(*args, &block) }

      it 'uses the cache if the value has been computed' do
        expect(memoizer.cache).to receive(:[]).with([args, block]).and_call_original
        is_expected.to eq value
      end
    end
  end

  context 'when there are no arguments or blocks' do
    include_examples 'a memoized method', [], nil, 26
  end

  context 'when there are arguments' do
    include_examples 'a memoized method', [1, 2, 3], nil, 34
  end

  context 'when there is a block' do
    include_examples 'a memoized method', [], proc {}, 36
  end

  context 'when there are arguments and a block' do
    include_examples 'a memoized method', [1, 2, 3], proc {}, 53
  end
end