defmodule MeuBot.Commands do
  alias Nostrum.Api.Message

  # ── SEM PARÂMETRO ──────────────────────────

  def ping(msg) do
    Message.create(msg.channel_id, "Pong!")
  end

  def ajuda(msg) do
    texto = """
    Comandos disponíveis:
    !ping — verifica se o bot está online
    !clima <cidade> — mostra o clima atual de uma cidade
    !crypto <moeda> — mostra o preço atual de uma criptomoeda
    !conv <valor> <de> <para> — converte entre moedas (ex: !conv 100 USD BRL)
    !piada — conta uma piada aleatória
    !curiosidade <cidade> — mostra o clima e uma curiosidade sobre a cidade
    !lembrar <texto> — salva um lembrete
    !lembretes — lista seus lembretes salvos
    """
    Message.create(msg.channel_id, texto)
  end

def piada(msg) do
  url = "https://v2.jokeapi.dev/joke/Any?lang=pt"

  case HTTPoison.get(url) do
    {:ok, %{status_code: 200, body: body}} ->
      data = body |> Jason.decode!()
      case data["type"] do
        "twopart" ->
          setup = data |> Map.get("setup")
          delivery = data |> Map.get("delivery")
          Message.create(msg.channel_id, "#{setup}\n#{delivery}")
        "single" ->
          joke = data |> Map.get("joke")
          Message.create(msg.channel_id, joke)
        _ ->
          Message.create(msg.channel_id, "Nao consegui buscar uma piada agora.")
      end

    _ ->
      Message.create(msg.channel_id, "Nao consegui buscar uma piada agora.")
  end
end

  # ── UM PARÂMETRO ───────────────────────────

  def clima(msg, cidade) do
    api_key = Application.get_env(:meu_bot, :weather_api_key)
    url = "https://api.openweathermap.org/data/2.5/weather?q=#{cidade}&appid=#{api_key}&units=metric&lang=pt_br"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        data = body |> Jason.decode!()
        temp      = data |> get_in(["main", "temp"])
        descricao = data |> get_in(["weather", Access.at(0), "description"])
        umidade   = data |> get_in(["main", "humidity"])
        texto = """
        Clima em #{cidade}:
        Temperatura: #{temp}C
        Umidade: #{umidade}%
        Condicao: #{descricao}
        """
        Message.create(msg.channel_id, texto)

      {:ok, %{status_code: 404}} ->
        Message.create(msg.channel_id, "Cidade nao encontrada.")

      _ ->
        Message.create(msg.channel_id, "Erro ao buscar o clima.")
    end
  end

  def crypto(msg, moeda) do
    moeda_lower = moeda |> String.downcase()
    url = "https://api.coingecko.com/api/v3/simple/price?ids=#{moeda_lower}&vs_currencies=usd,brl"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        data = body |> Jason.decode!()
        case Map.get(data, moeda_lower) do
          nil ->
            Message.create(msg.channel_id, "Moeda nao encontrada. Tente: bitcoin, ethereum, dogecoin")
          precos ->
            usd = precos |> Map.get("usd")
            brl = precos |> Map.get("brl")
            texto = """
            #{moeda |> String.upcase()}:
            USD: $#{usd}
            BRL: R$#{brl}
            """
            Message.create(msg.channel_id, texto)
        end

      _ ->
        Message.create(msg.channel_id, "Erro ao buscar o preco da criptomoeda.")
    end
  end

  # ── DOIS OU MAIS PARÂMETROS ────────────────

  def converter(msg, resto) do
    case resto |> String.split(" ", trim: true) do
      [valor, de, para] ->
        api_key = Application.get_env(:meu_bot, :exchange_api_key)
        url = "https://v6.exchangerate-api.com/v6/#{api_key}/pair/#{de}/#{para}/#{valor}"

        case HTTPoison.get(url) do
          {:ok, %{status_code: 200, body: body}} ->
            resultado = body
              |> Jason.decode!()
              |> Map.get("conversion_result")
            texto = "#{valor} #{de} = #{resultado} #{para}"
            Message.create(msg.channel_id, texto)

          _ ->
            Message.create(msg.channel_id, "Erro na conversao. Verifique as moedas.")
        end

      _ ->
        Message.create(msg.channel_id, "Use: !conv <valor> <moeda_origem> <moeda_destino>\nEx: !conv 100 USD BRL")
    end
  end

  # ── PERSISTÊNCIA ───────────────────────────

  def lembrar(msg, texto) do
    msg.author.id
    |> MeuBot.Store.add_lembrete(texto)
    Message.create(msg.channel_id, "Anotado!")
  end

  def lembretes(msg) do
    case msg.author.id |> MeuBot.Store.get_lembretes() do
      [] ->
        Message.create(msg.channel_id, "Voce nao tem lembretes salvos.")
      lista ->
        itens = lista
          |> Enum.with_index(1)
          |> Enum.map(fn {item, i} -> "#{i}. #{item}" end)
          |> Enum.join("\n")
        Message.create(msg.channel_id, "Seus lembretes:\n#{itens}")
    end
  end

  # ──DUAS APIs ──

  def curiosidade(msg, cidade) do
    api_key = Application.get_env(:meu_bot, :weather_api_key)
    url_clima = "https://api.openweathermap.org/data/2.5/weather?q=#{cidade}&appid=#{api_key}&units=metric&lang=pt_br"

    with {:ok, %{status_code: 200, body: body_clima}} <- HTTPoison.get(url_clima),
         data_clima = body_clima |> Jason.decode!(),
         temp = data_clima |> get_in(["main", "temp"]),
         pais = data_clima |> get_in(["sys", "country"]),
         url_wiki = "https://pt.wikipedia.org/api/rest_v1/page/summary/#{URI.encode(cidade)}",
         {:ok, %{status_code: 200, body: body_wiki}} <- HTTPoison.get(url_wiki),
         data_wiki = body_wiki |> Jason.decode!(),
         resumo = data_wiki |> Map.get("extract") do

      texto = """
      #{cidade} (#{pais})
      Temperatura atual: #{temp}C

      Curiosidade:
      #{resumo |> String.slice(0, 300)}...
      """
      Message.create(msg.channel_id, texto)
    else
      _ ->
        Message.create(msg.channel_id, "Nao encontrei informacoes sobre essa cidade.")
    end
  end

end
