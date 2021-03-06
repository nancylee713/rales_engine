require 'rails_helper'

describe "Merchants API" do
  it "sends a list of merchants" do
    create_list(:merchant, 3)

    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants = JSON.parse(response.body)
    expect(merchants["data"].count).to eq(3)
  end

  it "can get one merchant by its id" do
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    merchant = JSON.parse(response.body)

    expect(response).to be_successful
    expect(merchant["data"]["id"].to_i).to eq(id)
  end

  it "it can find first instance by id" do
    id = create(:merchant).id

    get "/api/v1/merchants/find?id=#{id}"

    merchant = JSON.parse(response.body)
    expect(response).to be_successful
    expect(merchant["data"]["attributes"]["id"].to_i).to eq(id)
  end

  it "can find first instance by name" do
    name = create(:merchant).name
    name_ci = name.downcase

    get "/api/v1/merchants/find?name=#{name}"

    merchant = JSON.parse(response.body)
    expect(response).to be_successful
    expect(merchant["data"]["attributes"]["name"]).to eq(name)

    get "/api/v1/merchants/find?name=#{name_ci}"

    merchant = JSON.parse(response.body)
    expect(response).to be_successful
    expect(merchant["data"]["attributes"]["name"]).to eq(name)
  end

  it "can find first instance by created_at" do
    created_at = create(:merchant).created_at

    get "/api/v1/merchants/find?created_at=#{created_at}"

    merchant = JSON.parse(response.body)
    expect(response).to be_successful

    expected = Merchant.find(merchant["data"]["id"]).created_at
    expect(expected).to eq(created_at)
  end

  it "can find first instance by updated_at" do
    updated_at = create(:merchant).updated_at

    get "/api/v1/merchants/find?updated_at=#{updated_at}"

    merchant = JSON.parse(response.body)
    expect(response).to be_successful

    expected = Merchant.find(merchant["data"]["id"]).updated_at
    expect(expected).to eq(updated_at)
  end

  it "can find all instances by id" do
    id = create(:merchant).id

    get "/api/v1/merchants/find_all?id=#{id}"

    merchant = JSON.parse(response.body)

    expect(response).to be_successful

    expect(merchant["data"].count).to eq(1)

    expected = merchant["data"].all? { |hash| hash["attributes"]["id"] == id }
    expect(expected).to eq(true)
  end

  it "can find all instances by name" do
    name = "Williamson Group"
    merchants = create_list(:merchant, 3)
    Merchant.update_all(name: name)
    klein = create(:merchant, name: "Klein")

    get "/api/v1/merchants/find_all?name=#{name}"

    merchant = JSON.parse(response.body)

    expect(response).to be_successful

    expect(merchant["data"].count).to eq(3)

    expected = merchant["data"].all? { |hash| hash["attributes"]["name"] == name }
    expect(expected).to eq(true)

    get "/api/v1/merchants/find_all?name=#{name.downcase}"

    merchant = JSON.parse(response.body)

    expect(response).to be_successful

    expect(merchant["data"].count).to eq(3)

    expected = merchant["data"].all? { |hash| hash["attributes"]["name"] == name }
    expect(expected).to eq(true)
  end

  it "can find all instances by created at" do
    merchants = create_list(:merchant, 3)
    created_at = merchants.first.created_at

    get "/api/v1/merchants/find_all?created_at=#{created_at}"

    merchant = JSON.parse(response.body)

    expect(response).to be_successful

    expect(merchant["data"].count).to eq(3)

    expected = merchant["data"].all? { |hash| Merchant.find(hash["id"]).created_at = created_at }
    expect(expected).to eq(true)
  end

  it "can find all instances by updated at" do
    merchants = create_list(:merchant, 3)
    updated_at = merchants.first.updated_at

    get "/api/v1/merchants/find_all?updated_at=#{updated_at}"

    merchant = JSON.parse(response.body)

    expect(response).to be_successful

    expect(merchant["data"].count).to eq(3)

    expected = merchant["data"].all? { |hash| Merchant.find(hash["id"]).updated_at = updated_at }
    expect(expected).to eq(true)
  end

  it "can return a random resource" do
    merchants = create_list(:merchant, 5)

    get "/api/v1/merchants/random"

    merchant = JSON.parse(response.body)

    expect(response).to be_successful

    expect(merchant["data"].count).to eq(1)
    expect(merchant["data"].first["type"]).to eq("merchant")
    expect(merchant["data"].first["attributes"].keys).to eq(["id", "name"])
  end

  it "can return a collection of associated items" do
    merchant = create(:merchant)
    item_1 = create(:item, merchant_id: merchant.id)
    item_2 = create(:item, merchant_id: merchant.id)

    get "/api/v1/merchants/#{merchant.id}/items"

    items = JSON.parse(response.body)

    expect(response).to be_successful

    expected_type = items["data"].all? { |hash| hash["type"] == 'item' }
    expected_merchant_id = items["data"].all? { |hash| hash["attributes"]["merchant_id"] == merchant.id }

    expect(items["data"].size).to eq(2)
    expect(expected_type).to eq(true)
    expect(expected_merchant_id).to eq(true)
  end

  it "can return a collection of associated invoices" do
    merchant = create(:merchant)
    invoice_1 = create(:invoice, merchant_id: merchant.id)
    invoice_2 = create(:invoice, merchant_id: merchant.id)

    get "/api/v1/merchants/#{merchant.id}/invoices"

    invoices = JSON.parse(response.body)

    expect(response).to be_successful

    expected_type = invoices["data"].all? { |hash| hash["type"] == 'invoice' }
    expected_merchant_id = invoices["data"].all? { |hash| hash["attributes"]["merchant_id"] == merchant.id }

    expect(invoices["data"].size).to eq(2)
    expect(expected_type).to eq(true)
    expect(expected_merchant_id).to eq(true)
  end

  it "can return the customer who has conducted the most total number of successful transactions" do
    merchant = create(:merchant)
    customer_1 = create(:customer)
    invoice_1 = create(:invoice, customer_id: customer_1.id, merchant_id: merchant.id)
    transaction_1 = create(:transaction, invoice_id: invoice_1.id, result: "success")
    transaction_2 = create(:transaction, invoice_id: invoice_1.id, result: "success")

    customer_2 = create(:customer)
    invoice_2 = create(:invoice, customer_id: customer_2.id, merchant_id: merchant.id)
    transaction_3 = create(:transaction, invoice_id: invoice_2.id, result: "success")
    transaction_4 = create(:transaction, invoice_id: invoice_2.id, result: "failed")

    customer_3 = create(:customer)
    invoice_3 = create(:invoice, customer_id: customer_3.id, merchant_id: merchant.id)
    transaction_5 = create(:transaction, invoice_id: invoice_3.id, result: "failed")

    get "/api/v1/merchants/#{merchant.id}/favorite_customer"

    favorite_customer = JSON.parse(response.body)

    expect(response).to be_successful

    expect(favorite_customer["data"]["attributes"]["id"]).to eq(customer_1.id)
  end

  it "can return the top 2 merchants ranked by total revenue" do
    merchant_1 = create(:merchant, name: "merchant 1")
    item_1 = create(:item, merchant_id: merchant_1.id, unit_price: 10)
    invoice_1 = create(:invoice, merchant_id: merchant_1.id)
    invoice_item_1 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_1.id, quantity: 5)

    merchant_2 = create(:merchant, name: "merchant 2")
    item_2 = create(:item, merchant_id: merchant_2.id, unit_price: 5)
    invoice_2 = create(:invoice, merchant_id: merchant_2.id)
    invoice_item_2 = create(:invoice_item, invoice_id: invoice_2.id, item_id: item_2.id, quantity: 5)

    merchant_3 = create(:merchant, name: "merchant 3")
    item_3 = create(:item, merchant_id: merchant_3.id, unit_price: 1)
    invoice_3 = create(:invoice, merchant_id: merchant_3.id)
    invoice_item_3 = create(:invoice_item, invoice_id: invoice_3.id, item_id: item_3.id, quantity: 5)

    get "/api/v1/merchants/most_revenue?quantity=2"

    top_two_merchants = JSON.parse(response.body)

    expect(response).to be_successful

    expect(top_two_merchants["data"].first["attributes"]["id"]).to eq(merchant_1.id)
    expect(top_two_merchants["data"].first["attributes"]["name"]).to eq(merchant_1.name)

    expect(top_two_merchants["data"].second["attributes"]["id"]).to eq(merchant_2.id)
    expect(top_two_merchants["data"].second["attributes"]["name"]).to eq(merchant_2.name)
  end

  it "can return the total revenue for date x across all merchants" do
    date_one = "2012-03-16"
    date_two = "2012-04-16"

    merchant_1 = create(:merchant, name: "merchant 1")
    item_1 = create(:item, merchant_id: merchant_1.id, unit_price: 10)
    invoice_1 = create(:invoice, merchant_id: merchant_1.id)
    invoice_item_1 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_1.id, quantity: 5, created_at: date_one)
    invoice_item_1 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_1.id, quantity: 5, created_at: date_two)

    merchant_2 = create(:merchant, name: "merchant 2")
    item_2 = create(:item, merchant_id: merchant_2.id, unit_price: 5)
    invoice_2 = create(:invoice, merchant_id: merchant_2.id)
    invoice_item_2 = create(:invoice_item, invoice_id: invoice_2.id, item_id: item_2.id, quantity: 5, created_at: date_one)

    get "/api/v1/merchants/revenue?date=#{date_one}"

    result = JSON.parse(response.body)

    expect(response).to be_successful

    expected = {"total_revenue" => "75"}
    expect(result["data"]["attributes"]).to eq(expected)
  end
end
