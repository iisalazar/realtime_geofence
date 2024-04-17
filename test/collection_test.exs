defmodule CollectionTest do
  use ExUnit.Case

  import Mox

  test "add_geofence when there's no geofence return new state" do
    # arrange
    sample_geofence_id = 1
    initial_state = %Collection{collection_name: "test/1", points: [], geofence_ids: []}
    # act
    {:reply, :ok, state} =
      Collection.handle_call({:add_geofence, sample_geofence_id}, nil, initial_state)

    # assert
    assert state.geofence_ids == [sample_geofence_id]
  end

  test "handle_cast :set_point when point in current state call Geofence.handle_point" do
    point = %Point{x: 1, y: 2}
    sample_geofences = [10]

    initial_state = %Collection{
      collection_name: "test/1",
      points: [point],
      geofence_ids: sample_geofences
    }

    expect(GeofenceBehaviorMock, :handle_point, fn geofence_id, point_param ->
      assert geofence_id == Enum.at(sample_geofences, 0)
      assert point_param == point
    end)

    {:noreply, state} = Collection.handle_cast({:set_point, point}, initial_state)

    assert state == initial_state
  end

  test "handle_cast :set_point when point in current state do_nothing and return current state" do
    point = %Point{x: 1, y: 2}
    sample_geofences = []

    initial_state = %Collection{
      collection_name: "test/1",
      points: [point],
      geofence_ids: sample_geofences
    }

    expect(GeofenceBehaviorMock, :handle_point, fn geofence_id, point_param ->
      assert geofence_id == Enum.at(sample_geofences, 0)
      assert point_param == point
    end)

    {:noreply, state} = Collection.handle_cast({:set_point, point}, initial_state)

    assert state == initial_state
  end

  test "handle_cast :set_point when point not in current state add to state" do
    point = %Point{x: 1, y: 2}
    sample_geofences = []

    initial_state = %Collection{
      collection_name: "test/1",
      points: [],
      geofence_ids: sample_geofences
    }

    expect(GeofenceBehaviorMock, :handle_point, fn geofence_id, point_param ->
      assert geofence_id == Enum.at(sample_geofences, 0)
      assert point_param == point
    end)

    {:noreply, state} = Collection.handle_cast({:set_point, point}, initial_state)

    expected_state = %Collection{
      collection_name: "test/1",
      points: [point],
      geofence_ids: sample_geofences
    }

    assert state == expected_state
  end
end
