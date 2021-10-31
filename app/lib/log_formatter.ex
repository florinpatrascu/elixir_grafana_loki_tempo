defmodule FF.LoggerFormatter do
  @moduledoc """
  Custom Formatter for Loki, otherwise we emit GCP compatible log events.
  Graciously borrowed from Alexander Koutmos's examples, details here: https://akoutmos.com/post/elixir-logging-loki/
  """
  import Jason.Helpers, only: [json_map: 1]

  @behaviour LoggerJSON.Formatter

  @processed_metadata_keys ~w[pid file line function module application]a

  @severity_levels [
    debug: "DEBUG",
    info: "INFO",
    warning: "WARNING",
    warn: "WARNING",
    error: "ERROR"
  ]

  for {level, gcp_level} <- @severity_levels do
    def format_event(unquote(level), msg, ts, md, md_keys) do
      Map.merge(
        %{
          time: format_timestamp(ts),
          severity: unquote(gcp_level),
          message: IO.iodata_to_binary(msg)
        },
        format_metadata(md, md_keys)
      )
    end
  end

  def format_event(_level, msg, ts, md, md_keys) do
    Map.merge(
      %{
        time: format_timestamp(ts),
        severity: "DEFAULT",
        message: IO.iodata_to_binary(msg)
      },
      format_metadata(md, md_keys)
    )
  end

  defp format_metadata(md, md_keys) do
    LoggerJSON.take_metadata(md, md_keys, @processed_metadata_keys)
    |> maybe_put(:error, format_process_crash(md))
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp format_process_crash(md) do
    if crash_reason = Keyword.get(md, :crash_reason) do
      initial_call = Keyword.get(md, :initial_call)

      json_map(
        initial_call: format_initial_call(initial_call),
        reason: format_crash_reason(crash_reason)
      )
    end
  end

  defp format_initial_call(nil), do: nil

  defp format_initial_call({module, function, arity}),
    do: "#{module}.#{function}/#{arity}"

  defp format_crash_reason({:throw, reason}) do
    Exception.format(:throw, reason)
  end

  defp format_crash_reason({:exit, reason}) do
    Exception.format(:exit, reason)
  end

  defp format_crash_reason({%{} = exception, stacktrace}) do
    Exception.format(:error, exception, stacktrace)
  end

  defp format_crash_reason(other) do
    inspect(other)
  end

  # RFC3339 UTC "Zulu" format
  defp format_timestamp({date, time}) do
    [format_date(date), ?T, format_time(time), ?Z]
    |> IO.iodata_to_binary()
  end

  defp format_time({hh, mi, ss, ms}) do
    [pad2(hh), ?:, pad2(mi), ?:, pad2(ss), ?., pad3(ms)]
  end

  defp format_date({yy, mm, dd}) do
    [Integer.to_string(yy), ?-, pad2(mm), ?-, pad2(dd)]
  end

  defp pad3(int) when int < 10, do: [?0, ?0, Integer.to_string(int)]
  defp pad3(int) when int < 100, do: [?0, Integer.to_string(int)]
  defp pad3(int), do: Integer.to_string(int)

  defp pad2(int) when int < 10, do: [?0, Integer.to_string(int)]
  defp pad2(int), do: Integer.to_string(int)
end
