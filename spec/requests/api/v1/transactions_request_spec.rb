require 'rails_helper'

describe "Transactions API" do
  it "sends a list of transactions" do
    transaction_1 = create(:transaction, invoice_id: create(:invoice).id)
    transaction_2 = create(:transaction, invoice_id: create(:invoice).id)
    transaction_3 = create(:transaction, invoice_id: create(:invoice).id)

    get '/api/v1/transactions'

    expect(response).to be_successful

    transactions = JSON.parse(response.body)
    expect(transactions["data"].count).to eq(3)
  end

  it "can get one transaction by its id" do
    id = create(:transaction, invoice_id: create(:invoice).id).id

    get "/api/v1/transactions/#{id}"

    transaction = JSON.parse(response.body)

    expect(response).to be_successful
    expect(transaction["data"]["id"].to_i).to eq(id)
  end

  it "it can find first instance by id" do
    id = create(:transaction).id

    get "/api/v1/transactions/find?id=#{id}"

    transaction = JSON.parse(response.body)
    expect(response).to be_successful
    expect(transaction["data"]["attributes"]["id"].to_i).to eq(id)
  end

  it "can find first instance by invoice id" do
    invoice_id = create(:transaction).invoice_id

    get "/api/v1/transactions/find?invoice_id=#{invoice_id}"

    transaction = JSON.parse(response.body)
    expect(response).to be_successful
    expect(transaction["data"]["attributes"]["invoice_id"]).to eq(invoice_id)
  end

  it "can find first instance by credit_card_number" do
    credit_card_number = create(:transaction).credit_card_number

    get "/api/v1/transactions/find?credit_card_number=#{credit_card_number}"

    transaction = JSON.parse(response.body)
    expect(response).to be_successful
    expect(transaction["data"]["attributes"]["credit_card_number"]).to eq(credit_card_number)
  end

  it "can find first instance by result" do
    result = create(:transaction).result
    result_ci = result.downcase

    get "/api/v1/transactions/find?result=#{result}"

    transaction = JSON.parse(response.body)
    expect(response).to be_successful
    expect(transaction["data"]["attributes"]["result"]).to eq(result)

    get "/api/v1/transactions/find?result=#{result_ci}"

    transaction = JSON.parse(response.body)
    expect(response).to be_successful
    expect(transaction["data"]["attributes"]["result"]).to eq(result)
  end

  it "can find first instance by created_at" do
    created_at = create(:transaction).created_at

    get "/api/v1/transactions/find?created_at=#{created_at}"

    transaction = JSON.parse(response.body)
    expect(response).to be_successful

    expected = Transaction.find(transaction["data"]["id"]).created_at
    expect(expected).to eq(created_at)
  end

  it "can find first instance by updated_at" do
    updated_at = create(:transaction).updated_at

    get "/api/v1/transactions/find?updated_at=#{updated_at}"

    transaction = JSON.parse(response.body)
    expect(response).to be_successful

    expected = Transaction.find(transaction["data"]["id"]).updated_at
    expect(expected).to eq(updated_at)
  end

  it "can find all instances by id" do
    id = create(:transaction).id

    get "/api/v1/transactions/find_all?id=#{id}"

    transaction = JSON.parse(response.body)

    expect(response).to be_successful

    expect(transaction["data"].count).to eq(1)

    expected = transaction["data"].all? { |hash| hash["attributes"]["id"] == id }
    expect(expected).to eq(true)
  end

  it "can find all instances by invoice id" do
    invoice_id = 1
    transactions = create_list(:transaction, 3)
    Transaction.update_all(invoice_id: invoice_id)
    another_transaction = create(:transaction)

    get "/api/v1/transactions/find_all?invoice_id=#{invoice_id}"

    invoice_item = JSON.parse(response.body)

    expect(response).to be_successful

    expect(invoice_item["data"].count).to eq(3)

    expected = invoice_item["data"].all? { |hash| hash["attributes"]["invoice_id"] == invoice_id }
    expect(expected).to eq(true)
  end

  it "can find all instances by credit_card_number" do
    credit_card_number = "4330934842024570"
    transactions = create_list(:transaction, 3)
    Transaction.update_all(credit_card_number: credit_card_number)
    another_transaction = create(:transaction)

    get "/api/v1/transactions/find_all?credit_card_number=#{credit_card_number}"

    invoice_item = JSON.parse(response.body)

    expect(response).to be_successful

    expect(invoice_item["data"].count).to eq(3)

    expected = invoice_item["data"].all? { |hash| hash["attributes"]["credit_card_number"] == credit_card_number }
    expect(expected).to eq(true)
  end

  it "can find all instances by result" do
    result = "success"
    transactions = create_list(:transaction, 3)
    Transaction.update_all(result: result)
    another_transaction = create(:transaction, result: "failed")

    get "/api/v1/transactions/find_all?result=#{result}"

    invoice_item = JSON.parse(response.body)

    expect(response).to be_successful

    expect(invoice_item["data"].count).to eq(3)

    expected = invoice_item["data"].all? { |hash| hash["attributes"]["result"] == result }
    expect(expected).to eq(true)

    get "/api/v1/transactions/find_all?result=#{result.upcase}"

    invoice_item = JSON.parse(response.body)

    expect(response).to be_successful

    expect(invoice_item["data"].count).to eq(3)

    expected = invoice_item["data"].all? { |hash| hash["attributes"]["result"] == result }
    expect(expected).to eq(true)
  end


  it "can find all instances by created at" do
    transactions = create_list(:transaction, 3)
    created_at = transactions.first.created_at

    get "/api/v1/transactions/find_all?created_at=#{created_at}"

    transaction = JSON.parse(response.body)

    expect(response).to be_successful

    expect(transaction["data"].count).to eq(3)

    expected = transaction["data"].all? { |hash| Transaction.find(hash["id"]).created_at = created_at }
    expect(expected).to eq(true)
  end

  it "can find all instances by updated at" do
    transactions = create_list(:transaction, 3)
    updated_at = transactions.first.updated_at

    get "/api/v1/transactions/find_all?updated_at=#{updated_at}"

    transaction = JSON.parse(response.body)

    expect(response).to be_successful

    expect(transaction["data"].count).to eq(3)

    expected = transaction["data"].all? { |hash| Transaction.find(hash["id"]).updated_at = updated_at }
    expect(expected).to eq(true)
  end

  it "can return a random resource" do
    transactions = create_list(:transaction, 5)

    get "/api/v1/transactions/random"

    transaction = JSON.parse(response.body)

    expect(response).to be_successful

    expect(transaction["data"].count).to eq(1)
    expect(transaction["data"].first["type"]).to eq("transaction")
    expect(transaction["data"].first["attributes"].keys).to eq(["id", "invoice_id", "credit_card_number", "result"])
  end

  it "can return the associated invoice" do
    customer = create(:customer)
    invoice = create(:invoice, customer_id: customer.id)
    transaction = create(:transaction, invoice_id: invoice.id)

    get "/api/v1/transactions/#{transaction.id}/invoice"

    tr_invoice = JSON.parse(response.body)

    expect(response).to be_successful

    expect(tr_invoice["data"]["type"]).to eq('invoice')
    expect(tr_invoice["data"]["attributes"]["id"]).to eq(invoice.id)
    expect(tr_invoice["data"]["attributes"]["customer_id"]).to eq(customer.id)
  end
end
