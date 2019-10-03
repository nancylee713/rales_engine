require 'csv'

namespace :import do
  desc "Import customers from CSV file"

  task customer: :environment do
    puts "Imported Customer csv file to db"
    CSV.foreach('./data/customers.csv', headers:true) do |row|
      Customer.create(row.to_h)
    end
  end

  task invoice: :environment do
    puts "Imported Invoice csv file to db"
    CSV.foreach('./data/invoices.csv', headers:true) do |row|
      Invoice.create(row.to_h)
    end
  end

  task item: :environment do
    puts "Imported Item csv file to db"
    CSV.foreach('./data/items.csv', headers:true) do |row|
      row_hash = row.to_h
      row_hash['unit_price'] = (row_hash['unit_price'].to_i / 100.to_f).to_s

      Item.create(row_hash)
    end
  end

  task invoice_item: :environment do
    puts "Imported InvoiceItem csv file to db"
    CSV.foreach('./data/invoice_items.csv', headers:true) do |row|
      row_hash = row.to_h
      row_hash['unit_price'] = (row_hash['unit_price'].to_i / 100.to_f).to_s

      InvoiceItem.create(row_hash)
    end
  end

  task merchant: :environment do
    puts "Imported Merchant csv file to db"
    CSV.foreach('./data/merchants.csv', headers:true) do |row|
      Merchant.create(row.to_h)
    end
  end

  task transaction: :environment do
    puts "Imported Transaction csv file to db"
    CSV.foreach('./data/transactions.csv', headers:true) do |row|
      Transaction.create(row.to_h)
    end
  end

  task all: [:customer, :invoice, :item, :invoice_item, :merchant, :transaction]
end
