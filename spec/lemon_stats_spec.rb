require 'spec_helper'

describe LemonStats do
	BASE_KEY = "stats".freeze
	subject { LemonStats.new BASE_KEY }

	it 'has a version number' do
		expect(LemonStats::VERSION).not_to be nil
	end

	it 'The base key is set in the stats collection and group too' do
		expect(subject.base_key).to eq(BASE_KEY)
		expect(subject.store_collection.base_store_key).to eq(BASE_KEY)
	end

	context "Stats store collection" do
		before(:each) do
			@test = instance_spy("LemonStats::StatsStore", "TestStore", :type => :test_store, :id => "main")
			allow(@test).to receive(:save_stats).and_return(true)
			allow(@test).to receive(:save_stat).and_return(true)
			subject.add_store(@test)
		end

		it 'Add a stats store' do
			expect(@test).to have_received(:set_key).with(BASE_KEY)
			expect(subject.store_collection.length).to eq(1)
		end

		it 'Find stats store by type' do
			expect(subject.find_store("main")).to eq(@test)
		end

		it 'Add another stat store' do
			ss2 = instance_spy("LemonStats::StatsStore", "AnotherStore", :type => :test_store, :id => "test2")
			allow(ss2).to receive(:save_stats).and_return(true)
			allow(ss2).to receive(:save_stat).and_return(true)
			subject.add_store(ss2)

			expect(subject.find_store("test2")).to eq(ss2)
		end

		it 'Remove a stats store' do
			expect(subject.remove_store(@test)).to eq(@test)			
		end
	end

	it 'Add, Get and Remove a stat' do

	end

	it 'Try get a non-existant stat' do

	end

	it 'Try remove a non existant stat' do

	end

	context "After adding stats" do
		before(:example) do
		
		end

		it 'Get stats by group' do
		
		end

		it 'Update a stat' do

		end

		it 'Update a group of stats' do

		end

	end
end
