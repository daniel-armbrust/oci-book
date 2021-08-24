# Capítulo 1: Conceitos e introdução a Computação em Nuvem no OCI

## 1.6 - Introdução aos principais serviços do OCI

### __Principais Serviços__

https://www.oracle.com/cloud/data-regions/

### __IAM (Identity and Access Management)__

A principal função do serviço _[IAM](https://docs.oracle.com/pt-br/iaas/Content/Identity/Concepts/overview.htm)_ é a _Gestão de Identidades e Acessos_. 

Através dele é possivel especificar qual o **_tipo de acesso_** que um **_grupo de usuários_** possui, sobre determinados **_recursos_**. É aqui que você identifica, autentica e controla o acesso (autorização) de indivíduos ou aplicações, que utilizam os recursos do OCI (no seu tenant pra ser mais exato).

>_**__NOTA:__** Um **recurso** é um "objeto de nuvem" que você cria no OCI. Por exemplo: instâncias de computação, volumes de armazenamento em blocos, redes virtuais, etc._

Ao criar sua conta da conta no OCI, você começa com uma única identidade de login que tem acesso total a todos os recursos e serviços do seu _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_. Este primeiro usuário criado recebe o título de _"Administrador do Tenant"_ ou _"Administrador Padrão"_. 

O privilégio de _"acesso total"_, é concedido através de uma _política de segurança (policy)_ que dá ao grupo **Administrators**, acesso a todas as operações das APIs do OCI e a todos os recursos do seu _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_. Para se ter o privilégio de _"acesso total"_, basta o usuário ser membro do grupo **Administrators**. 

>_**__NOTA:__** Não é possível excluir o grupo **Administrators** e sempre deve haver pelo menos um usuário membro. Também não é possível alterar nem excluir esta política, que concede os direitos de administrador._

#### __Usuários e Grupos__

Um novo _[Tenant](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_ criado nasce "fechado". É função do _Administrador_ criar e disponibilizar acesso a novos usuários.

Um **usuário** é um indivíduo da sua organização que precisa gerenciar ou usar os recursos do seu _[Tenant](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_. Um usuário não precisa ser uma pessoa. Ele também pode representar uma aplicação.

O serviço _[IAM](https://docs.oracle.com/pt-br/iaas/Content/Identity/Concepts/overview.htm)_ utiliza a combinação _"nome do usuário" (username)_ e _"senha"_ para autenticação. Uma _"senha"_ pode ser uma combinação de caracteres alfanuméricos ou ser representado através de uma _"[chave de acesso](https://docs.oracle.com/pt-br/iaas/Content/Identity/Concepts/usercredentials.htm)"_ (método normalmente usado por aplicações).

>_**__NOTA:__** Recomendamos que você não use as credenciais do usuário administrador para acesso diário. Recomendamos também que você não compartilhe suas credenciais do usuário administrador com outras pessoas, pois isso oferece a eles acesso irrestrito ao seu [tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)._

Utilize o comando abaixo para se criar um novo usuário:

```
darmbrust@hoodwink:~$ oci iam user create --name "mflores" --email "maria@algumdominio.com.br" --description "Maria das Flores"    
{
  "data": {
    "capabilities": {
      "can-use-api-keys": true,
      "can-use-auth-tokens": true,
      "can-use-console-password": true,
      "can-use-customer-secret-keys": true,
      "can-use-o-auth2-client-credentials": true,
      "can-use-smtp-credentials": true
    },
    "compartment-id": "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-08-23T18:29:11.203Z"
      }
    },
    "description": "Maria das Flores",
    "email": "maria@algumdominio.com.br",
    "email-verified": false,
    "external-identifier": null,
    "freeform-tags": {},
    "id": "ocid1.user.oc1..aaaaaaaagpov2dclzaxb4hoyapkwnwsdcymlvsl3fgrjuhdzka34kd4fmxbq",
    "identity-provider-id": null,
    "inactive-status": null,
    "is-mfa-activated": false,
    "last-successful-login-time": null,
    "lifecycle-state": "ACTIVE",
    "name": "mflores",
    "previous-successful-login-time": null,
    "time-created": "2021-08-23T18:29:11.340000+00:00"
  },
  "etag": "b2efa082d75f6a8be5b445f96259f1c3638688ba"
}
```

Agora, é preciso definir uma senha de acesso. Primeiramente, iremos obter o OCID no qual representa o usuário "mflores" para então definir a nova senha:

```
darmbrust@hoodwink:~$ oci iam user list --query "data[?name=='mflores'].id"
[
  "ocid1.user.oc1..aaaaaaaagpov2dclzaxb4hoyapkwnwsdcymlvsl3fgrjuhdzka34kd4fmxbq"
]
```

```
darmbrust@hoodwink:~$ oci iam user ui-password create-or-reset --user-id ocid1.user.oc1..aaaaaaaagpov2dclzaxb4hoyapkwnwsdcymlvsl3fgrjuhdzka34kd4fmxbq
{
  "data": {
    "inactive-status": null,
    "lifecycle-state": "ACTIVE",
    "password": "MxmB5<EAkFKCiy9k[9zA",
    "time-created": "2021-08-24T10:40:49.628000+00:00",
    "user-id": "ocid1.user.oc1..aaaaaaaagpov2dclzaxb4hoyapkwnwsdcymlvsl3fgrjuhdzka34kd4fmxbq"
  },
  "etag": "05bd43fc36fae50a0f32d808854efe53c5103b78"
}
```

>_**__NOTA:__** Para saber mais detalhes sobre os filtros em documentos JSON, consulte este link [aqui](https://jmespath.org/)_. 

Um **grupo** é um meio de se organizar usuários que terão permissões em comum. Quando se cria um novo grupo, você deve fornecer um nome exclusivo e inalterável. Este nasce sem nenhuma permissão até que você defina uma política (policy), que dá determinado acesso aos usuários membros do grupo. Lembrando que um usuário pode ser membro de diferentes grupos.

Para se criar um grupo, usamos o comando abaixo:

```
darmbrust@hoodwink:~$ oci iam group create --name "grp-netadm" --description "Usuários administradores dos recursos de rede."
{
  "data": {
    "compartment-id": "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-08-23T16:07:49.894Z"
      }
    },
    "description": "Usu\u00e1rios administradores dos recursos de rede.",
    "freeform-tags": {},
    "id": "ocid1.group.oc1..aaaaaaaatafagegoyy56srtflrknuxzmzmhfgzfyclrbh7ozderdo4z52gda",
    "inactive-status": null,
    "lifecycle-state": "ACTIVE",
    "name": "grp-netadm",
    "time-created": "2021-08-23T16:07:49.909000+00:00"
  },
  "etag": "4918daacc579081cbec733d939a831da9f1adfa5"
}
```

Igual a todos os outros recursos, um grupo também possui um OCID exclusivo:

```
darmbrust@hoodwink:~$ oci iam group list --query 'data[].[name, id]'
[
  [
    "Administrators",
    "ocid1.group.oc1..aaaaaaaazhxisz5ho2c3scyxnn4ezvs3gmowq7uuxqekpd65lwpykywzwm4q"
  ],
  [
    "grp-dba",
    "ocid1.group.oc1..aaaaaaaapqaq4mp2p2yaf5yqut4vcy4i5smhiz22crwim3z363ytvwexk3ta"
  ]
]
```