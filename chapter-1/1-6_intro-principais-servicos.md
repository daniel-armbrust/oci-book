# Capítulo 1: Conceitos e introdução a Computação em Nuvem no OCI

## 1.6 - Introdução aos principais serviços do OCI

### __Principais Serviços__

https://www.oracle.com/cloud/data-regions/

### __IAM (Identity and Access Management)__

A principal função do serviço _[IAM](https://docs.oracle.com/pt-br/iaas/Content/Identity/Concepts/overview.htm)_ é a _Gestão de Identidades e Acessos_. 

Através dele é possivel especificar qual o **_tipo de acesso_** que um **_grupo de usuários_** possui, sobre determinados **_recursos_**. É aqui que você identifica, autentica e controla o acesso (autorização) de indivíduos ou aplicações, que utilizam os recursos do OCI (no seu tenant pra ser mais exato).

>_**__NOTA:__** Um **recurso** é um "objeto de nuvem" que você cria no OCI. Por exemplo: instâncias de computação, volumes de armazenamento em blocos, redes virtuais, etc._

Ao criar sua conta da conta no OCI, você começa com uma única identidade de login que tem acesso total a todos os recursos e serviços do seu _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_. Este primeiro usuário criado recebe o título de _"Administrador do Tenant"_ ou _"Administrador Padrão"_. 

O privilégio de _"acesso total"_, é concedido através de uma _política de segurança (policy)_ que concede ao grupo **Administrators**, acesso a todas as operações das APIs do OCI e a todos os recursos do seu _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_. Para se ter o privilégio de _"acesso total"_, basta o usuário ser membro do grupo **Administrators**. 

>_**__NOTA:__** Não é possível excluir o grupo **Administrators** e sempre deve haver pelo menos um usuário membro. Também não é possível alterar nem excluir esta política, que concede os direitos de administrador._

#### __Usuários e Grupos__

Quando criamos uma nova conta ou _[Tenant](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_, este nasce "fechado". É função do _Administrador_ criar e disponibilizar acesso a novos usuários.

Um usuário é um indivíduo da sua organização que precisa gerenciar ou usar os recursos do seu _[Tenant](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_. Um usuário não precisa ser uma pessoa. Ele pode representar uma aplicação também. 

O serviço _[IAM](https://docs.oracle.com/pt-br/iaas/Content/Identity/Concepts/overview.htm)_ utiliza a combinação _"nome do usuário" (username)_ e _"senha"_ para autenticação. Uma _"senha"_ pode ser uma combinação de caracteres alfanuméricos ou ser representado através de _"[chaves de acesso](https://docs.oracle.com/pt-br/iaas/Content/Identity/Concepts/usercredentials.htm)"_ (método normalmente usado por aplicações).

>_**__NOTA:__** Recomendamos que você não use as credenciais do usuário administrador para acesso diário. Recomendamos também que você não compartilhe suas credenciais do usuário administrador com outras pessoas, pois isso oferece a eles acesso irrestrito ao seu [tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)._