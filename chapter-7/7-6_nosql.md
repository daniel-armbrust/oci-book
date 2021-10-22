# Capítulo 7: Banco de Dados

## 7.6 - Oracle NoSQL

### __Visão Geral__

Os bancos de dados do tipo _[NoSQL](https://pt.wikipedia.org/wiki/NoSQL)_ são uma nova abordagem para armazenamento e gerenciamento de dados, que difere do _[modelo relacional](https://pt.wikipedia.org/wiki/Modelo_relacional)_ que conhecemos. Falando um pouco do _[modelo relacional](https://pt.wikipedia.org/wiki/Modelo_relacional)_, este armazena os dados em _tabelas_, sendo que cada _tabela_ é dividida em _linhas (tuplas)_ e _colunas_. Tais _tabelas_ podem ou não se relacionar umas com as outras, formando _relações_.

Essa é  a base de todo o _modelo relacional: "Tabelas que se relacionam com outras tabelas, para possibilitar a organização e recuperação de dados"._

![alt_text](./images/modelo_relacional_1.jpg "Modelo Relacional")

Tecnologias _[NoSQL](https://pt.wikipedia.org/wiki/NoSQL)_ foram desenvolvidas para suportar aplicações que manipulam grandes volumes de dados, e que necessitam de um _**modelo de dados mais flexível**_, sem _esquema fixo_ ou _schemaless_. Aplicações para _redes sociais_, _e-commerce_ e _[IoT](https://pt.wikipedia.org/wiki/Internet_das_coisas)_ são alguns tipos de aplicações que se beneficiam de tecnologias _[NoSQL](https://pt.wikipedia.org/wiki/NoSQL)_ por possuírem tal esquema de dados dinâmico.

Abaixo um exemplo de dados de um _e-commerce_, onde há benefícios ao se utilizar um _modelo de dados schemaless_:

![alt_text](./images/nosql_3.jpg "Modelo de dados Schemaless")

Uma outra importante característica sobre os bancos _[NoSQL](https://pt.wikipedia.org/wiki/NoSQL)_, é que eles foram projetados para serem executados em _[clusters de computadores](https://pt.wikipedia.org/wiki/Cluster)_ favorecendo a _"escalabilidade horizontal"_, onde o _[modelo relacional](https://pt.wikipedia.org/wiki/Modelo_relacional)_ é incompatível.

O termo _[NoSQL](https://pt.wikipedia.org/wiki/NoSQL)_ _("Not SQL" ou "Not Only SQL")_ não está definido de uma forma muito clara. Ele é utilizado por alguns bancos de dados não relacionais recentes como os de nome _[Redis](https://pt.wikipedia.org/wiki/Redis)_, _[MongoDB](https://pt.wikipedia.org/wiki/MongoDB)_, _[Oracle NoSQL Database](https://en.wikipedia.org/wiki/Oracle_NoSQL_Database)_, _[Neo4J](https://en.wikipedia.org/wiki/Neo4j)_, entre outros.

Já adianto a informação de que os banco de dados do tipo _[NoSQL](https://pt.wikipedia.org/wiki/NoSQL)_ não substituem os banco de dados relacionais, e nem o contrário também é verdade. _[Bancos de dados NoSQL](https://pt.wikipedia.org/wiki/NoSQL)_, contendo dados _não estruturados_, complementam _bancos de dados SQL_, que contém _dados estruturados_. Nos dias de hoje, como bons arquitetos de solução, devemos entender onde determinada tecnologia _"se encaixa melhor"_ e assim fazer um melhor uso.

>_**__NOTA:__** Todos os conceitos apresentados neste post têm como base o [Oracle NoSQL Database](https://en.wikipedia.org/wiki/Oracle_NoSQL_Database) no modelo on-premises e cloud. Porém, o objetivo é explicar o serviço no modelo cloud computing. Muitos dos conceitos do modelo on-premises, podem ser aplicados no modelo cloud. A documentação oficial do modelo on-premises você encontra [aqui](https://docs.oracle.com/en/database/other-databases/nosql-database/). Já a documentação do modelo cloud, é [aqui](https://www.oracle.com/br/database/nosql-cloud.html) e também [aqui](https://docs.oracle.com/pt-br/iaas/nosql-database/index.html)._

### __A origem do NoSQL__

O principal propósito de um banco de dados está na sua capacidade de armazenar grandes quantidades de dados. Bancos relacionais têm a importante missão de persistir os dados de forma segura, além de ter que lidar com múltiplos acessos concorrentes através das transações.

A _transação_ é quem garante a _**consistência dos dados**_, ajudando a lidar com possíveis problemas ou erros no processamento. Através das transações é possível adicionar, apagar ou modificar múltiplos registros entre diferentes _tabelas_, e decidir se queremos _persistir as alterações (commit)_ ou _descartá-las (rollback)_. Por conta disso, até então, os _bancos de dados relacionais (RDBMS)_ têm sido a escolha padrão para _aplicações comerciais (enterprise)_.

>_**__NOTA:__** O termo transação aqui refere-se a [transações ACID](https://pt.wikipedia.org/wiki/ACID) (Atômicas, Consistentes, Isoladas e Duráveis). Muitas linhas existentes em diferentes tabelas são atualizadas através de uma única operação. Transações incorporam a noção de unidade de trabalho, tem sucesso total ou falha total (tudo ou nada), e nunca um meio termo. Tipicamente, envolvem múltiplas operações em diferentes entidades de dados._

Para entendermos melhor o _[NoSQL](https://pt.wikipedia.org/wiki/NoSQL)_, temos que relembrar os conceitos que envolvem a palavra _escalabilidade_. Uma das vantagens em se utilizar a _Computação em Nuvem_, está ligado a _escalabilidade dos recursos_ (ajustar o sistema à capacidade desejada). Para contextualizar:

- _Escalabilidade Vertical (Scale UP/DOWN)_: refere-se a ação de aumentar ou diminuir os recursos existentes em uma máquina. Por exemplo, adicionar mais memória RAM ou trocar o processador por outro, com um clock mais rápido.

- _Escalabilidade Horizontal (Scale OUT/IN)_: refere-se a ação de adicionar mais máquinas a um conjunto existente de máquinas. Quanto mais máquinas trabalhando em conjunto, mais processamento temos. É aqui que temos o conceito de computação distribuída em _[cluster de computadores](https://pt.wikipedia.org/wiki/Cluster)_.

Uma das principais diferenças entre os dois modos apresentados, está em relação ao custo. Basicamente, escalar uma máquina verticalmente é financeiramente mais caro e exige _tempo de indisponibilidade_. Ao longo do tempo, descobriu-se que adicionar mais máquinas menores para trabalharem juntas, é financeiramente mais barato e _não exige tempo de indisponibilidade_.

O problema é que um _banco de dados relacional_, não consegue aplicar os conceitos de _escalabilidade horizontal_, por conta do funcionamento das _transações_. _[Transações ACID](https://pt.wikipedia.org/wiki/ACID)_ são incompatíveis com execução em _[cluster de computadores](https://pt.wikipedia.org/wiki/Cluster)_. Não se combinam, pois não há como garantir a _consistência dos dados_, ou mesmo realizar um _[JOIN](https://pt.wikipedia.org/wiki/Join_(SQL))_ sobre os dados que estão distribuídos no _[cluster](https://pt.wikipedia.org/wiki/Cluster)_.

![alt_text](./images/rdbms_1.jpg "Banco de Dados Relacional")

Vale lembrar que o modelo relacional possui grande flexibilidade ao processar as relações entre diferentes tabelas. Podemos executar um _[JOIN](https://pt.wikipedia.org/wiki/Join_(SQL))_ e retornar qualquer visualização que se queira dos dados através da união de diferentes tabelas (flexibilidade na apresentação ou composição, dos dados existentes em diferentes tabelas).

>_**__NOTA:__** Como veremos, existem algumas tecnologias de bancos de dados NoSQL que suportam [transações ACID](https://pt.wikipedia.org/wiki/ACID) ou mesmo um relacionamento de dados limitado, possibilitando também, JOINs limitados._

Já um banco de dados _[NoSQL](https://pt.wikipedia.org/wiki/NoSQL)_, surgiu da necessidade de processar grandes volumes de dados _não relacionados_. O fato dos dados não terem relacionamentos entre si, e possuírem um _modelo de dados mais simples_, sem um _esquema fixo (schemaless)_, possibilitou sua execução em grandes _[cluster de computadores](https://pt.wikipedia.org/wiki/Cluster)_, favoráveis ao _escalonamento horizontal_.

![alt_text](./images/nosql_1.jpg "NoSQL - clusters de computadores")

A partir disso, podemos dizer que os bancos de dados _[NoSQL](https://pt.wikipedia.org/wiki/NoSQL)_ são _altamente distribuídos_, não necessitam de hardware sofisticado, e fornecem suporte transacional mínimo ou nenhum.

Quando há a necessidade de executar técnicas de _[desnormalização](https://pt.wikipedia.org/wiki/Normaliza%C3%A7%C3%A3o_de_dados#Desnormaliza%C3%A7%C3%A3o)_, ou mesmo quando as regras de negócio tendem a levar a criação do chamado _"tabelão" (termo usado por DBAs e desenvolvedores de software para criar tabelas que não possuem relacionamentos, ou que não seguem as regras da [normalização de dados](https://pt.wikipedia.org/wiki/Normaliza%C3%A7%C3%A3o_de_dados))_, talvez seja a hora de empregar o _[NoSQL](https://pt.wikipedia.org/wiki/NoSQL)_ em sua solução tecnológica.

Diferentes problemas são resolvidos por diferentes tecnologias. E isso se aplica também quando falamos de banco de dados. Diferentes bancos de dados para diferentes tipos de dados. Essa afirmação é muitas vezes chamada de _[Persistência Poliglota](https://en.wikipedia.org/wiki/Polyglot_persistence)_.

### __Banco de dados Relacional vs. NoSQL__

Já destacamos as principais diferenças entre os tipos de bancos de dados quando falamos do surgimento do NoSQL. 

Abaixo, uma tabela de rápida fixação:

![alt_text](./images/rdbms_vs_nosql_1.jpg "Relacional vs. NoSQL")

### __Tipos de Banco de Dados NoSQL__

A maioria dos bancos _[NoSQL](https://pt.wikipedia.org/wiki/NoSQL)_ é alguma derivação de uma estrutura _chave/valor_. 

Existem quatro grandes categorias mais utilizadas:

![alt_text](./images/tipos_nosql.jpg "Tipos NoSQL")

- **Armazenamento Chave/Valor**
    - Os dados são armazenados através de _chaves_ únicas. O banco de dados não conhece e também não se importa com o _valor_ que uma _chave_ faz referência. Para o banco de dados, é somente um conjunto de bits (_[blobs](https://pt.wikipedia.org/wiki/BLOB)_).
    - Pelo fato do banco não conhecer os dados, só é possível recuperar tais dados através de consultas que envolvam os _valores da chave_.
    - _Casos de uso_: Sessão de usuário em aplicações Web, carrinho de compras.
    - Alguns tipos de bancos _[NoSQL](https://pt.wikipedia.org/wiki/NoSQL)_ que se enquadram nessa categoria são: _[Riak](https://en.wikipedia.org/wiki/Riak)_, _[Redis](https://pt.wikipedia.org/wiki/Redis)_ ou _[Oracle NoSQL Database](https://docs.oracle.com/pt-br/iaas/nosql-database/index.html)_.