# -*- encoding : utf-8 -*-
require 'ashikawa-core/status'

describe Ashikawa::Core::Status do
  subject { Ashikawa::Core::Status }

  describe 'a new born collection' do
    subject { Ashikawa::Core::Status.new(1) }
    its(:new_born?) { should be_truthy }
    its(:unloaded?) { should be_falsey }
    its(:loaded?) { should be_falsey }
    its(:being_unloaded?) { should be_falsey }
    its(:corrupted?) { should be_falsey }
  end

  describe 'an unloaded collection' do
    subject { Ashikawa::Core::Status.new(2) }
    its(:new_born?) { should be_falsey }
    its(:unloaded?) { should be_truthy }
    its(:loaded?) { should be_falsey }
    its(:being_unloaded?) { should be_falsey }
    its(:corrupted?) { should be_falsey }
  end

  describe 'a loaded collection' do
    subject { Ashikawa::Core::Status.new(3) }
    its(:new_born?) { should be_falsey }
    its(:unloaded?) { should be_falsey }
    its(:loaded?) { should be_truthy }
    its(:being_unloaded?) { should be_falsey }
    its(:corrupted?) { should be_falsey }
  end

  describe 'a collection being unloaded' do
    subject { Ashikawa::Core::Status.new(4) }
    its(:new_born?) { should be_falsey }
    its(:unloaded?) { should be_falsey }
    its(:loaded?) { should be_falsey }
    its(:being_unloaded?) { should be_truthy }
    its(:corrupted?) { should be_falsey }
  end

  describe 'a corrupted collection' do
    subject { Ashikawa::Core::Status.new(6) }
    its(:new_born?) { should be_falsey }
    its(:unloaded?) { should be_falsey }
    its(:loaded?) { should be_falsey }
    its(:being_unloaded?) { should be_falsey }
    its(:corrupted?) { should be_truthy }
  end
end
