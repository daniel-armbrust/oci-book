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

