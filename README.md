Bot para o Discord desenvolvido em Elixir com o framework Nostrum

## Requisitos

- Elixir 1.14 ou superior
- Mix (já incluído com o Elixir)
- Conta no Discord e um bot criado no Discord Developer Portal

## Configuração

1. Clone o repositório:

```bash
git clone https://github.com/Luccs3003/Meu_bot.git
cd meu_bot
```

2. Instale as dependências:

```bash
mix deps.get
```

3. Crie o arquivo `config/config.exs` baseado no exemplo:

```bash
cp config/config.example.exs config/config.exs
```

4. Preencha o `config/config.exs` com suas chaves:

```elixir
import Config

config :nostrum,
  token: "SEU_TOKEN_DO_DISCORD",
  gateway_intents: :all

config :meu_bot,
  weather_api_key: "SUA_CHAVE_OPENWEATHER",
  exchange_api_key: "SUA_CHAVE_EXCHANGERATE"
```

## Como executar

```bash
mix run --no-halt
```

Ou com terminal interativo:

```bash
iex -S mix
```

## Comandos disponíveis

| Comando | Exemplo | Descrição |
|---|---|---|
| `!ping` | `!ping` | Verifica se o bot está online |
| `!ajuda` | `!ajuda` | Lista todos os comandos disponíveis |
| `!piada` | `!piada` | Conta uma piada aleatória em português |
| `!clima` | `!clima Fortaleza` | Mostra o clima atual de uma cidade |
| `!crypto` | `!crypto bitcoin` | Mostra o preço atual de uma criptomoeda |
| `!conv` | `!conv 100 USD BRL` | Converte entre moedas |
| `!lembrar` | `!lembrar Reunião às 10h` | Salva um lembrete |
| `!lembretes` | `!lembretes` | Lista seus lembretes salvos |
| `!curiosidade` | `!curiosidade Fortaleza` | Mostra clima e curiosidade sobre a cidade |

## Arquitetura

O projeto é organizado em quatro módulos:

- `MeuBot` — ponto de entrada e Supervisor principal
- `MeuBot.Consumer` — recebe eventos do Discord e despacha comandos via pattern matching
- `MeuBot.Commands` — implementação de cada comando
- `MeuBot.Store` — leitura e escrita do arquivo JSON de persistência

## APIs utilizadas

- **OpenWeatherMap** — clima e temperatura
- **CoinGecko** — preços de criptomoedas
- **ExchangeRate API** — conversão de moedas
- **JokeAPI** — piadas em português
- **Wikipedia API** — curiosidades sobre cidades

## Tecnologias

- Elixir
- Mix
- Nostrum (Discord)
- HTTPoison (requisições HTTP)
- Jason (serialização JSON)
