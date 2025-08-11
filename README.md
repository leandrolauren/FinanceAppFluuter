# Finance App

Um aplicativo Flutter para gerenciamento financeiro, permitindo cálculos de juros compostos e consulta de cotações de ações. O aplicativo suporta autenticação de usuário, temas claro e escuro, e integração com uma API para obter dados financeiros.

## Funcionalidades

- **Autenticação**: Tela de login com validação de usuário e senha.
- **Calculadora de Juros Compostos**: Permite calcular o crescimento de investimentos com base em valor inicial, aporte mensal, taxa de juros anual e período em meses. Exibe resultados em tabelas e gráficos (linha, barras e pizza).
- **Consulta de Ações**: Busca cotações de ações por ticker, com detalhes como preço atual, variação, setor, P/L, entre outros. Os tickers salvos são persistidos localmente.
- **Temas Claro/Escuro**: Suporte a temas dinâmicos que seguem a configuração do sistema (claro ou escuro).
- **Navegação Segura**: Redireciona rotas inexistentes para a tela de login e protege rotas com autenticação via middleware.
- **Logout**: Limpa dados de autenticação e tickers salvos no `SharedPreferences`.

## Estrutura do Projeto

```
finance_app/
├── lib/
│   ├── main.dart                    # Ponto de entrada do aplicativo
│   ├── login_page.dart             # Tela de login
│   ├── auth_middleware.dart        # Middleware para controle de autenticação
│   ├── navigation_page.dart        # Tela de navegação principal
│   ├── stock_page.dart             # Tela de listagem de ações
│   ├── stock_details_page.dart     # Tela de detalhes de uma ação
│   ├── calculator_page.dart        # Tela de cálculo de juros compostos
│   ├── services.dart               # Serviços de API e gerenciamento de autenticação
├── pubspec.yaml                   # Configuração de dependências
├── README.md                      # Este arquivo
```

### Arquivos Principais

- **main.dart**: Configura o aplicativo, inicializa dependências e define temas claro/escuro.
- **login_page.dart**: Interface de login com validação e bloqueio do botão de voltar.
- **auth_middleware.dart**: Garante que apenas usuários autenticados acessem rotas protegidas.
- **navigation_page.dart**: Tela inicial com botões para acessar a calculadora e a lista de ações.
- **stock_page.dart**: Exibe uma grade de ações salvas e permite adicionar novas por ticker.
- **stock_details_page.dart**: Mostra detalhes de uma ação específica.
- **calculator_page.dart**: Interface para cálculos de juros compostos com visualizações gráficas.
- **services.dart**: Gerencia chamadas à API, autenticação e persistência de tokens.

## Pré-requisitos

- **Flutter**: Versão 3.0.0 ou superior
- **Dart**: Versão compatível com o Flutter
- **Dependências** (listadas em `pubspec.yaml`):
  - `flutter`
  - `shared_preferences`
  - `http`
  - `fl_chart`
  - `intl`
  - `data_table_2`

## Instalação

1. **Clone o repositório**:

   ```bash
   git clone <https://github.com/leandrolauren/FinanceAppFluuter.git>
   cd finance_app
   ```

2. **Instale as dependências**:

   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo**:
   ```bash
   flutter run
   ```

## Uso

1. **Login**:

   - Na tela inicial, insira um nome de usuário e senha válidos.
   - Após login bem-sucedido, você será redirecionado para a tela de navegação.

2. **Calculadora de Juros Compostos**:

   - Acesse a calculadora a partir da tela de navegação.
   - Insira o valor inicial, aporte mensal, taxa de juros anual e período em meses.
   - Visualize os resultados em uma tabela e gráficos.

3. **Consulta de Ações**:

   - Acesse a seção de ações na tela de navegação.
   - Digite um ticker (ex.: AAPL) para buscar cotações.
   - Toque em uma ação para ver detalhes.
   - Os tickers são salvos localmente e recarregados automaticamente.

4. **Logout**:
   - Clique no ícone de logout na barra superior para limpar os dados de autenticação e tickers salvos.

## Configuração do Tema

O aplicativo suporta temas claro e escuro, alternando automaticamente com base na configuração do sistema. As definições de tema estão em `main.dart`:

- **Tema Claro**: Usa cores claras com `brightness: Brightness.light`.
- **Tema Escuro**: Usa cores escuras com `brightness: Brightness.dark`.
- Personalize os temas em `_buildLightTheme` e `_buildDarkTheme` conforme necessário.

## Dependências

As dependências principais estão listadas em `pubspec.yaml`. Certifique-se de incluí-las:

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.0.15
  http: ^0.13.5
  fl_chart: ^0.55.2
  intl: ^0.17.0
  data_table_2: ^2.3.9
```

## Notas de Desenvolvimento

- **Autenticação**: O middleware (`auth_middleware.dart`) verifica o token em `SharedPreferences` antes de permitir acesso a rotas protegidas.
- **API**: As chamadas à API (`services.dart`) usam autenticação via token JWT, com suporte a renovação de token.
- **Gráficos**: A calculadora usa `fl_chart` para exibir gráficos de linha, barras e pizza, formatados com `intl` para moedas em reais (R$).
- **Persistência**: Os tickers de ações são salvos em `SharedPreferences` para recarregamento na inicialização.

## Possíveis Melhorias

- Adicionar suporte offline para dados de ações.
- Implementar filtros na lista de ações (ex.: por setor ou variação).
- Adicionar validações mais robustas nos campos da calculadora.
- Incluir testes unitários e de integração.
- Suportar múltiplos idiomas com internacionalização.

## Licença

Este projeto é de código aberto e está sob a licença MIT.

---

Desenvolvido usando Flutter.
