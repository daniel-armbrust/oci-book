# Capítulo 4: Primeira aplicação no OCI

## 4.3 - Apresentando o Serviço Bastion

### __Visão Geral__

O _[Serviço Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_ do OCI permite você acessar de forma segura, através de sessões SSH e por tempo limitado, os recursos da sua infraestrutura que não possuem endereço IP público. Um Bastion é uma entidade lógica gerenciada pela Oracle e que deve ser criado em uma subrede pública. Ao ser provisionado, ele cria a infraestrutura de rede necessária para se conectar aos recursos existentes em uma subrede privada.

Bastions podem ser usados a vontade, de acordo com os limites disponíveis no seu _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_, e não geram custos. É um serviço gratuito.


