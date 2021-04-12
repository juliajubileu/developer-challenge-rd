# CustomerSuccess Balancing

Para ver detalhes sobre a solução, clique [aqui](#sobre-a-solução)! 


Este desafio consiste em um sistema de balanceamento entre clientes e Customer Success (CSs). Os CSs são os Gerentes de Sucesso, são responsáveis pelo acompanhamento estratégico dos clientes.

Dependendo do tamanho do cliente - aqui nos referimos ao tamanho da empresa - nós temos que colocar CSs mais experientes para atendê-los.

Um CS pode atender mais de um cliente e além disso os CSs também podem sair de férias, tirar folga, ou mesmo ficarem doentes. É preciso levar esses critérios em conta na hora de rodar a distribuição.

Dado este cenário, o sistema distribui os clientes com os CSs de capacidade de atendimento mais próxima (maior) ao tamanho do cliente.

### Exemplo

Se temos 6 clientes com os seguintes níveis: 20, 30, 35, 40, 60, 80 e dois CSs de níveis 50 e 100, o sistema deveria distribui-los da seguinte forma:

- 20, 30, 35, 40 para o CS de nível 50
- 60 e 80 para o CS de nível 100

Sendo `n` o número de CSs, `m` o númro de clientes e `t` o número de abstenções de CSs, calcular quais clientes serão atendidos por quais CSs de acordo com as regras apresentadas.


### Premissas

- Todos os CSs têm níveis diferentes
- Não há limite de clientes por CS
- Clientes podem ficar sem ser atendido
- Clientes podem ter o mesmo tamanho
- 0 < n < 1.000
- 0 < m < 1.000.000
- 0 < id do cs < 1.000
- 0 < id do cliente < 1.000.000
- 0 < nível do cs < 10.000
- 0 < tamanho do cliente < 100.000
- Valor máximo de t = n/2 arredondado para baixo

## Input

A classe recebe 3 parâmetros:

- id e nivel da experiencia do CS
- id e nivel de experiência dos Clientes
- ids dos CustomerSuccess indisponíveis


## Output

O resultado esperado deve ser o id do CS que atende mais clientes. Com esse valor a empresa poderá fazer um plano de ação para contratar mais CS's de um nível aproximado.

Em caso de empate retornar `0`.

### Exemplo

No input de exemplo, CS's 2 e 4 estão de folga, sendo assim o CS 1 vai atender os clientes de tamanho até 60 (clientes 2, 4, 5, 6), enquanto o CS 3 vai atender os clientes 1 e 3.

Para este exemplo o retorno deve ser `1`, que é o id do CS que atende 4 clientes:

```
1
```

## Sobre a solução

Para resolver o exercício, implementei um algoritmo que atribui um grupo de clientes ao CS mais experiente para atendê-lo, de acordo com as premissas do desafio e seguindo os seguintes passos: 

**1. Gerar um array com os CSs ativos.**
 Subtraindo os CSs indisponíveis da lista de CSs.

**2. Iterar pela lista de CSs ativos para atribuir todos os Customers ao CS mais experiente para atendê-lo naquele grupo.**
 Cada vez que um grupo de Customers é associado ao CS que irá atendê-lo, estes Customers são excluídos do array de Customers que podem ser distribuídos a outros CSs. 
 Desta forma, cada CS só irá iterar sobre os Customers que ainda estão sem atendimento, tornando o algoritmo mais performático.

**3. Identificar o CS com o maior número de Customers**
 Partindo de uma seleção dos dois CSs com o maior número de Customers, checar se houve empate, ou se nenhum CS era experiente o suficiente para atender o grupo de Customers (casos em que retornamos 0) ou, caso contrário, retornar o ID do CS que está atendendo mais Customers.

### Como executar o código

Para executar o código localmente, você deve instalar a linguagem [Ruby versão 2.7.2](https://www.ruby-lang.org/pt/) e seguir as instruções abaixo:

Clone este repositório
```bash
git clone https://github.com/JuliaJubileu/developer-challenge-rd
```

Abra o diretório pelo terminal

```bash
cd developer-challenge-rd
```

Caso não tenha a gem **minitest** instalada, rode o comando abaixo

```bash
gem install minitest
```

Execute os testes, rodando o seguinte comando no terminal

```bash
ruby customer_success_balancing.rb
```

### Possíveis melhorias

Quando o programa recebe inputs em desacordo com as premissas estabelecidas no desafio, nenhum erro é levantado. Por isso, pode ser desenvolvido um sistema de exceções que torne o programa mais preparado para erros. Considerando a instrução de näo editar os testes existentes, decidi não implementar este sistema no momento, pois quebraria o teste 5 (Este teste inclui dois CSs com mesmo nível).

Além disso, seria interessante estudar outras soluções que tornem o código mais versátil. Possibilitando, por exemplo, obter os IDs dos CSs com menos Customers, no caso de uma mudança no escopo.
