require 'spec_helper'

describe LemonStats::BaseStat do

	NAME = :total
	TYPE = :test
	GROUP = 'test:group:one'
	INIT_VAL = 500

	subject { LemonStats::BaseStat.new NAME, GROUP, TYPE, INIT_VAL }

	it 'Has correct name' do
		expect(subject.name).to eq(NAME)
	end

	it 'Has correct group' do
		expect(subject.group).to eq(GROUP)
	end

	it 'Has correct type' do
		expect(subject.type).to eq(TYPE)
	end

	it 'Initial value is correct and stat is dirty' do
		expect(subject.value).to eq(INIT_VAL)
		expect(subject.dirty).to eql(true)
	end

	it 'Invalid group throws an error' do
		expect{subject.group = 'hello test group'}.to raise_error(LemonStats::GroupError)
	end

end
