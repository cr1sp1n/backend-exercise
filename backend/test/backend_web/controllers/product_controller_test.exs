defmodule BackendWeb.ProductControllerTest do
  use BackendWeb.ConnCase

  import Backend.ProductsFixtures

  alias Backend.Products.Product

  @create_attrs %{
    id: "some_product_#{Enum.random(1..10000)}",
    name: "some name",
    price: 4200
  }
  @update_attrs %{
    name: "some updated name",
    price: 4300
  }
  @invalid_attrs %{name: nil, price: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      conn = get(conn, Routes.product_path(conn, :index))
      assert json_response(conn, 200)["products"] == []
    end
  end

  describe "create product" do
    test "renders product when data is valid", %{conn: conn} do
      conn = post(conn, Routes.product_path(conn, :create), product: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["product"]

      conn = get(conn, Routes.product_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => "some name",
               "price" => 42.0
             } = json_response(conn, 200)["product"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.product_path(conn, :create), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      conn = put(conn, Routes.product_path(conn, :update, product), product: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["product"]

      conn = get(conn, Routes.product_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => "some updated name",
               "price" => 43.0
             } = json_response(conn, 200)["product"]
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put(conn, Routes.product_path(conn, :update, product), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete(conn, Routes.product_path(conn, :delete, product))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Routes.product_path(conn, :show, product))
      end)
    end
  end

  defp create_product(_) do
    product = product_fixture()
    %{product: product}
  end
end
