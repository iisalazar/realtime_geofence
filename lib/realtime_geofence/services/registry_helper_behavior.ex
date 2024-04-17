defmodule RegistryHelperBehavior do
  @callback create_key(any()) :: {:via, atom, {atom, String.t()}}
  @callback create_key(any(), :collection) :: {:via, atom, {atom, String.t()}}

  @callback get_pid(String.t()) :: pid
  @callback get_pid(String.t(), :collection) :: pid
end
