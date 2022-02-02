defmodule Backend.OrderServiceTest do
  use Backend.DataCase

  alias Backend.Orders.{Item, Order}
  alias Backend.{OrderService, Users}

  describe "order service" do
    import Backend.{ProductsFixtures, UsersFixtures}

    test "create_order/2 should create order with one product" do
      user = user_fixture(%{balance: 700})
      products = [product_fixture(%{price: 300})]
      products_ids = Enum.map(products, fn p -> p.id end)

      assert {:ok, %{create_order: {%Order{}, [%Item{}]}}} =
               OrderService.create_order(user.user_id, products_ids)
    end

    test "create_order/2 should not create order with insufficient balance" do
      user = user_fixture(%{balance: 299})
      products = [product_fixture(%{price: 300})]
      products_ids = Enum.map(products, fn p -> p.id end)

      assert {:error, :create_order, "insufficient_balance", _} =
               OrderService.create_order(user.user_id, products_ids)
    end

    test "create_order/2 should create orders concurrently for same user and keep balance consistent" do
      user = user_fixture(%{balance: 1000})

      products = [
        product_fixture(%{price: 150}),
        product_fixture(%{price: 140}),
        product_fixture(%{price: 130}),
        product_fixture(%{price: 120}),
        product_fixture(%{price: 110}),
        product_fixture(%{price: 100}),
        product_fixture(%{price: 90})
      ]

      tasks =
        products
        |> Enum.map(fn p ->
          Task.async(fn ->
            OrderService.create_order(user.user_id, [p.id])
          end)
        end)

      Task.await_many(tasks)

      {:ok, user} = Users.get_user(user.user_id)

      assert 160 = user.balance
    end
  end
end
