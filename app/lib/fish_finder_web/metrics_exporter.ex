defmodule FFWeb.MetricsExporter do
  @moduledoc false

  use Prometheus.PlugExporter
end

defmodule FFWeb.PipelineInstrumenter do
  use Prometheus.PlugPipelineInstrumenter
end
