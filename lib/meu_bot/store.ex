defmodule MeuBot.Store do
  use GenServer

  @file_path "lembretes.json"

  # ── API pública ──────────────────────────────────────

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_lembrete(user_id, texto) do
    GenServer.call(__MODULE__, {:add, to_string(user_id), texto})
  end

  def get_lembretes(user_id) do
    GenServer.call(__MODULE__, {:get, to_string(user_id)})
  end

  # ── Callbacks do GenServer ───────────────────────────

  @impl true
  def init(_) do
    state = load_from_file()
    {:ok, state}
  end

  @impl true
  def handle_call({:add, user_id, texto}, _from, state) do
    lembretes = Map.get(state, user_id, [])
    new_state = Map.put(state, user_id, lembretes ++ [texto])
    save_to_file(new_state)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:get, user_id}, _from, state) do
    {:reply, Map.get(state, user_id, []), state}
  end

  # ── Funções privadas ─────────────────────────────────

  defp load_from_file do
    case File.read(@file_path) do
      {:ok, content} -> Jason.decode!(content)
      {:error, _}    -> %{}
    end
  end

  defp save_to_file(data) do
    data
    |> Jason.encode!(pretty: true)
    |> then(&File.write!(@file_path, &1))
  end
end
