# Capítulo 1: Conceitos e introdução a Computação em Nuvem no OCI

## 1.6 - Introdução aos principais serviços do OCI

### __Principais Serviços__

https://www.oracle.com/cloud/data-regions/

### __IAM (Identity and Access Management)__

O serviço _[IAM](https://docs.oracle.com/pt-br/iaas/Content/Identity/Concepts/overview.htm)_ do OCI permite que você especifique qual o **_tipo de acesso_** que um **_grupo de usuários_** possui, sobre determinados **_recursos_**. Através do _[IAM](https://docs.oracle.com/pt-br/iaas/Content/Identity/Concepts/overview.htm)_ é que você identifica, autentica e controla o acesso (autorização) de indivíduos ou aplicações, que utilizam os recursos do OCI (no seu tenant pra ser exato).

>_**__NOTA:__** Um **recurso** é um "objeto de nuvem" que você cria no OCI. Por exemplo: instâncias de computação, volumes de armazenamento em blocos, redes virtuais, etc._

Você cria sua conta no OCI através da combinação de um _"nome de usuário"_ e _"senha"_. Este primeiro usuário criado, recebe o título de _"Administrador do Tenant"_ e possui _"acesso total"_. O privilégio de _"acesso total"_, é concedido através de uma _política de segurança (policy)_ que concede ao grupo **Administrators**, acesso a todas as operações da API do OCI, e a todos os recursos de nuvem do seu _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_. Para se ter o privilégio de _"acesso total"_, basta o usuário ser membro do grupo **Administrators**. 

>_**__NOTA:__** Não é possível excluir o grupo **Administrators** e sempre deve haver pelo menos um usuário membro. Também não é possível alterar nem excluir esta política, que concede os direitos de administrador._

Vamos começar com os conceitos básicos do serviço.
