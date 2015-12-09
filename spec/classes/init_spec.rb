require 'spec_helper'
describe 'windows_baseline' do

  context 'with defaults for all parameters' do
    it { should contain_class('windows_baseline') }
  end
end
