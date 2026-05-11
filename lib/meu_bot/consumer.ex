defmodule MeuBot.Consumer do
  use Nostrum.Consumer

  alias MeuBot.Commands

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!ping" ->
        Commands.ping(msg)

      "!ajuda" ->
        Commands.ajuda(msg)

      "!lembretes" ->
        Commands.lembretes(msg)

      "!lembrar " <> texto ->
        Commands.lembrar(msg, texto)

      "!clima " <> cidade ->
        Commands.clima(msg, cidade)

      "!crypto " <> moeda ->
        Commands.crypto(msg, moeda)

      "!conv " <> resto ->
        Commands.converter(msg, resto)

      "!piada" ->
        Commands.piada(msg)

      "!curiosidade " <> cidade ->
        Commands.curiosidade(msg, cidade)

      _ ->
        :ignore
    end
  end

  def handle_event(_event), do: :ok
end
