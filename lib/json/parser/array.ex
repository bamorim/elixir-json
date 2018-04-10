defmodule JSON.Parser.Array do
  @moduledoc """
  Implements a JSON Array Parser for Bitstring values
  """

  alias JSON.Parser, as: Parser
  import Parser, only: [trim: 1]

  @doc """
  parses a valid JSON array value, returns its elixir list representation

  ## Examples

      iex> JSON.Parser.Array.parse ""
      {:error, :unexpected_end_of_buffer}

      iex> JSON.Parser.Array.parse "[1, 2 "
      {:error, :unexpected_end_of_buffer}

      iex> JSON.Parser.Array.parse "face0ff"
      {:error, {:unexpected_token, "face0ff"}}

      iex> JSON.Parser.Array.parse "[] lala"
      {:ok, [], " lala"}

      iex> JSON.Parser.Array.parse "[]"
      {:ok, [], ""}

      iex> JSON.Parser.Array.parse "[\\\"foo\\\", 1, 2, 1.5] lala"
      {:ok, ["foo", 1, 2, 1.5], " lala"}
  """
  def parse(<<?[, rest::binary>>) do
    rest |> trim |> parse_array_contents
  end

  def parse(<<>>), do: {:error, :unexpected_end_of_buffer}
  def parse(json), do: {:error, {:unexpected_token, json}}

  # begin parse array
  defp parse_array_contents(json) when is_binary(json), do: parse_array_contents([], json)

  # stop condition
  defp parse_array_contents(acc, <<?], rest::binary>>), do: {:ok, Enum.reverse(acc), rest}

  # error condition
  defp parse_array_contents(_, <<>>), do: {:error, :unexpected_end_of_buffer}

  defp parse_array_contents(acc, json) do
    case json |> trim |> Parser.parse() do
      {:error, error_info} ->
        {:error, error_info}

      {:ok, value, after_value} ->
        after_value = trim(after_value)

        case after_value do
          <<?,, after_comma::binary>> ->
            parse_array_contents([value | acc], trim(after_comma))

          _ ->
            parse_array_contents([value | acc], after_value)
        end
    end
  end
end