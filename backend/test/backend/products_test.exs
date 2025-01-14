defmodule Backend.ProductsTest do
  use Backend.DataCase

  alias Backend.Products

  describe "products" do
    alias Backend.Products.Product

    import Backend.ProductsFixtures

    @invalid_attrs %{name: nil, price: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Products.list_products() == [product]
    end

    test "get_products/1 returns products by ids list" do
      products = [product_fixture(), product_fixture()]
      ids = products |> Enum.map(fn it -> it.id end)
      assert {:ok, products_fetched} = Products.get_products(ids)
      assert products_fetched == products
    end

    test "get_products/1 returns empty list if any id supplied doesn't have product" do
      product = product_fixture()
      ids = [product.id, "non-existent-id"]
      assert {:ok, []} = Products.get_products(ids)
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{id: "some-product", name: "some name", price: 42}

      assert {:ok, %Product{} = product} = Products.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.price == 42
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{name: "some updated name", price: 43}

      assert {:ok, %Product{} = product} = Products.update_product(product, update_attrs)
      assert product.name == "some updated name"
      assert product.price == 43
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_product(product, @invalid_attrs)
      assert product == Products.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end
end
