defmodule DurationParser do
  @moduledoc """
  Parse a given string as either a time interval or a fractional number of hours
  and return the equivalent number of hours and minutes.

  ## Examples

      iex> DurationParser.parse_minutes("2:15")
      {:ok, 135}

      iex> DurationParser.parse_minutes("02:15")
      {:ok, 135}

      iex> DurationParser.parse_minutes("2h 35m")
      {:ok, 155}

      iex> DurationParser.parse_minutes("10")
      {:ok, 10}

      iex> DurationParser.parse_minutes("0.5h")
      {:ok, 30}

      iex> DurationParser.parse_minutes("0.5")
      {:ok, 30}

      iex> DurationParser.parse_minutes("10.0")
      {:ok, 600}

      iex> DurationParser.parse_minutes("7.5")
      {:ok, 450}

      iex> DurationParser.parse_minutes("24.5")
      {:ok, 1470}

      iex> DurationParser.parse_minutes("a24.5")
      {:error, "expected 2 digits"}
  """

  def parse_minutes(input) when is_binary(input) and byte_size(input) > 0 do
    input = input |> String.trim() |> String.downcase()
    cond do
      String.contains?(input, ":")  -> parse_time(input)
      String.contains?(input, " ")  -> parse_hm_time(input)
      String.contains?(input, ".")  -> parse_float(input)
      true                          -> parse_int(input)
    end
  end
  def parse_minutes(_), do: {:error, "expected string input"}

  defp parse_time(input) do
    with [h, m] <- String.split(input, ":", parts: 2),
         {{h, ""}, {m, ""}} <- {Integer.parse(h), Integer.parse(m)} do
      {:ok, h * 60 + m}
    else
      _ -> {:error, "expected h:mm or hh:mm format"}
    end
  end

  defp parse_hm_time(input) do
    with [h, m] <- String.split(input, ~r/\s+/, parts: 2),
         {{h, "h"}, {m, "m"}} <- {Integer.parse(h), Integer.parse(m)} do
      {:ok, h * 60 + m}
    else
      _ -> {:error, "expected 1h 30m format"}
    end
  end

  defp parse_int(input) do
    case Integer.parse(input) do
      {h, "h"}  -> {:ok, h * 60}
      {m, "m"}  -> {:ok, m}
      {m, _}    -> {:ok, m}
      _         -> {:error, "expected 2 digits"}
    end
  end

  defp parse_float(input) do
    case Float.parse(input) do
      {h, "h"}  -> {:ok, round(h * 60)}
      {m, "m"}  -> {:ok, round(m)}
      {h, ""}   -> {:ok, round(h * 60)}
      _         -> {:error, "expected 2 digits"}
    end
  end
end
