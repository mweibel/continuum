#          DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                  Version 2, December 2004
#
#          DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
# TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 
#
# 0. You just DO WHAT THE FUCK YOU WANT TO.

defmodule Continuum.Timezone do
  @type t      :: String.t
  @type offset :: { :+ | :-, Time.t }

  alias Continuum.Timezone.Database

  @doc """
  Using Timezone will import the guard clauses.
  """
  defmacro __using__(_opts) do
    quote do
      import Continuum.Timezone, only: [is_timezone: 1, is_timezone: 2]
      require Continuum.Timezone.Database
    end
  end

  @spec is_timezone(term) :: boolean
  defmacro is_timezone(zone) do
    quote do
      Database.contains?(unquote(zone))
    end
  end

  @spec is_timezone(term, t) :: boolean
  defmacro is_timezone(zone, name) when is_binary(name) do
    zones = Timezone.synonyms_for name

    quote do
      unquote(zone) in unquote(zones)
    end
  end

  defdelegate exists?(timezone),      to: Database
  defdelegate get(timezone),          to: Database
  defdelegate timezone == other,      to: Database, as: :equals?
  defdelegate link_to(timezone),      to: Database
  defdelegate link?(timezone),        to: Database
  defdelegate synonyms_for(timezone), to: Database

  def local do
    now       = :erlang.now
    universal = :calendar.now_to_universal_time(now) |> DateTime.to_epoch
    local     = :calendar.now_to_local_time(now) |> DateTime.to_epoch
    offset    = local - universal

    if offset >= 0 do
      { :+, Time.new(seconds: offset) }
    else
      { :-, Time.new(seconds: -offset) }
    end |> from_offset
  end

  @spec offset(DateTime.t) :: offset
  def offset(datetime) do
    offset("UTC", datetime)
  end

  def offset(zone, datetime) do
    { :+, { 0, 0, 0 } }
  end

  @spec from_offset(offset) :: t
  def from_offset({ _, { 0, 0, 0 } }) do
    "UTC"
  end

  def from_offset(offset) do

  end
end
