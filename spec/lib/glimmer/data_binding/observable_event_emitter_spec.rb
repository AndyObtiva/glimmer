require 'spec_helper'
require 'glimmer/data_binding/observer'
require 'glimmer/data_binding/observable_event_emitter'

describe Glimmer::DataBinding::ObservableEventEmitter do
  before :all do
    class Order
      include Glimmer::DataBinding::ObservableEventEmitter
      
      ORDER_TOTAL_VALUE = 83.28
      PRODUCT_PRICES_ARRAY = [3.23, 40, 20, 20]
    
      def calculate_order_total
        notify_observers(:order_total, ORDER_TOTAL_VALUE)
        ORDER_TOTAL_VALUE
      end
    
      def determine_product_prices
        notify_observers(:product_prices, PRODUCT_PRICES_ARRAY)
        PRODUCT_PRICES_ARRAY
      end
      
      def perform_work
        notify_observers(:work_done)
      end
    end
  end
  
  after :all do
    Object.send(:remove_const, :Order) if Object.const_defined?(:Order)
  end
  
  it 'adds observer and triggers event' do
    order = Order.new
    
    @observer_called = nil
    Glimmer::DataBinding::Observer.proc do |new_value|
      @observer_called = new_value
    end.observe(order, :order_total)
    expect(@observer_called).to be_nil
    
    order.calculate_order_total
    
    expect(@observer_called).to eq(Order::ORDER_TOTAL_VALUE)
  end
  
  it 'adds observer and triggers event with nil value' do
    order = Order.new
    
    @observer_called = :not_nil
    Glimmer::DataBinding::Observer.proc do |new_value|
      @observer_called = new_value
    end.observe(order, :work_done)
    expect(@observer_called).to eq(:not_nil)
    
    order.perform_work
    
    expect(@observer_called).to be_nil
  end
  
  it 'adds 2 observer and triggers event' do
    order = Order.new
    
    @observer1_called = nil
    Glimmer::DataBinding::Observer.proc do |new_value|
      @observer1_called = new_value
    end.observe(order, :order_total)
    expect(@observer1_called).to be_nil
    
    @observer2_called = nil
    Glimmer::DataBinding::Observer.proc do |new_value|
      @observer2_called = new_value
    end.observe(order, :order_total)
    expect(@observer2_called).to be_nil
    
    order.calculate_order_total
    
    expect(@observer1_called).to eq(Order::ORDER_TOTAL_VALUE)
    expect(@observer2_called).to eq(Order::ORDER_TOTAL_VALUE)
  end
  
  it 'adds 2 observer and triggers 2 events twice each' do
    order = Order.new
    
    @observer1_called = nil
    Glimmer::DataBinding::Observer.proc do |new_value|
      @observer1_called = new_value
    end.observe(order, :order_total)
    expect(@observer1_called).to be_nil
    
    @observer2_called = nil
    Glimmer::DataBinding::Observer.proc do |new_value|
      @observer2_called = new_value
    end.observe(order, :order_total)
    expect(@observer2_called).to be_nil
    
    @observer3_called = nil
    Glimmer::DataBinding::Observer.proc do |new_value|
      @observer3_called = new_value
    end.observe(order, :product_prices)
    expect(@observer3_called).to be_nil
    
    @observer4_called = nil
    Glimmer::DataBinding::Observer.proc do |new_value|
      @observer4_called = new_value
    end.observe(order, :product_prices)
    expect(@observer4_called).to be_nil
    
    order.calculate_order_total
    
    expect(@observer1_called).to eq(Order::ORDER_TOTAL_VALUE)
    expect(@observer2_called).to eq(Order::ORDER_TOTAL_VALUE)
    
    order.determine_product_prices
    
    expect(@observer3_called).to eq(Order::PRODUCT_PRICES_ARRAY)
    expect(@observer4_called).to eq(Order::PRODUCT_PRICES_ARRAY)
  end
  
  it 'adds no observers and triggers event' do
    order = Order.new
    
    expect(order.calculate_order_total).to eq(Order::ORDER_TOTAL_VALUE)
  end
  
  it 'adds observer, removes observer while specifying event, and triggers event' do
    order = Order.new
    
    @observer_called = nil
    observer = Glimmer::DataBinding::Observer.proc do |new_value|
      @observer_called = new_value
    end
    order.add_observer(observer, :order_total)
    expect(@observer_called).to be_nil
    
    order.remove_observer(observer, :order_total)
    
    order.calculate_order_total
    
    expect(@observer_called).to be_nil
  end
  
  it 'adds as observer of all events, not a specific event, triggers multiple events' do
    order = Order.new
    
    @observer_called = nil
    Glimmer::DataBinding::Observer.proc do |new_value, event|
      @observer_called = [new_value, event]
    end.observe(order)
    expect(@observer_called).to be_nil
    
    order.calculate_order_total
    
    expect(@observer_called).to eq([Order::ORDER_TOTAL_VALUE, :order_total])
    
    order.determine_product_prices
    
    expect(@observer_called).to eq([Order::PRODUCT_PRICES_ARRAY, :product_prices])
  end
  
  it 'adds as observer of all events, removes as observer of all events, not a specific event, triggers multiple events' do
    order = Order.new
    
    @observer_called = nil
    observer = Glimmer::DataBinding::Observer.proc do |new_value, event|
      @observer_called = [new_value, event]
    end
    order.add_observer(observer)
    expect(@observer_called).to be_nil
    
    order.remove_observer(observer)
    
    expect(order.calculate_order_total).to eq(Order::ORDER_TOTAL_VALUE)
    
    expect(@observer_called).to be_nil
    
    expect(order.determine_product_prices).to eq(Order::PRODUCT_PRICES_ARRAY)
    
    expect(@observer_called).to be_nil
  end
  
  it 'removes all observers for an event'
end
