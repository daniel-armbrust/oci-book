# Capítulo 4: Primeira aplicação no OCI

## 4.1 - Fundamentos de Redes no OCI

### __Visão Geral da Rede no OCI__

Uma das primeiras etapas ao começar a implementar seus recursos no OCI, é a configuração da sua rede. o serviço de _[Networking do OCI](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/overview.htm)_ disponibiliza versões virtuais dos componentes de redes tradicionais no qual você pode usar. Configurar a rede de dados é um pré-requisito para que você possa criar seus recursos.

Aprensento abaixo, alguns dos componentes existentes do serviço de _[Networking do OCI](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/overview.htm)_:

1. **VCN (Virtual Cloud Network)**
    - É uma rede virtual privada configurada nos data centers da Oracle e que reside em uma única região.
    - A partir de uma VCN criada e configurada, podemos criar subredes, máquinas virtuais, banco de dados, etc. É o nosso “tapete” para acomodarmos os móveis, a mesa, o sofá e a televisão.
    - Para criar uma VCN, você deve escolher um bloco de endereços IPv4 válido. A Oracle recomenda escolher um dos blocos documentados pela _[RFC1918](https://tools.ietf.org/html/rfc1918)_:
        - 10.0.0.0/8
        - 172.16.0.0/12
        - 192.168.0.0/16

2. **Subredes**
    - É a divisão de uma VCN em partes menores (subdivisões).
    - Cada subrede consiste em um intervalo contíguo de endereços IP (para IPv4 e IPv6, se ativado) que não se sobrepõem com outras subredes da VCN.    
    - Você pode criar uma subrede em um único _"domínio de disponibilidade"_ ou em uma região (subrede regional - _modo recomendado_).
    - Recursos criados dentro de uma subrede utilizam a mesma tabela de roteamento (route table), as mesmas listas de segurança (security lists), e mesmas opções de DHCP (dhcp options).
    - Você cria uma subrede como sendo pública ou privada. Uma subrede pública permite expor, através de IP público, um recurso na internet. A subrede privada, não.

3. **Tabelas de Roteamento (Route Table)**
    - Contém regras de roteamento que direcionam o tráfego da subrede “para fora” da VCN.
    - Subredes dentro da mesma VCN, não precisam de regras de roteamento para se comunicarem.
    
4. **Regras de Segurança (Security Lists)** 
    - É o firewall virtual aplicado na "borda" de uma subrede.
    - Todo o tráfego que entra e saí, de todos os recursos da subrede, é avaliado por este tipo de firewall.
    - Tudo é bloqueado por padrão. É possível liberar o tráfego de rede por protocolos e portas, IPv4 ou IPv6.

5. **Grupos de segurança de rede (NSG - Network Security Groups)**
    - É um outro tipo de firewall virtual, porém este é aplicado sobre uma ou várias VNICs.
    - Quando você cria um NSG, ele inicialmente está vazio, sem regras de segurança ou VNICs.  

6. **VNIC (Virtual Network Interface Card)**
    - O termo vem de _[NIC (network interface card)](https://pt.wikipedia.org/wiki/Placa_de_rede)_. É uma interface de rede virtual ou VNIC.
    - Todo recurso que se comunica com outros recursos da rede, criam uma VNIC que está associada às NICs físicas do serviço de redes do OCI.
    - Toda VNIC obrigatóriamente reside em uma subrede.
    - Uma VNIC pode ter até 31 endereços IPv4 privados, um endereço IPv4 público opcional para cada IP privado e até 32 endereços IPv6 opcionais.

7. **Opções de DHCP (DHCP Options)**
    - São configurações informadas pelo protocolo DHCP a todos os recursos criados dentro de uma subrede. 
    - É possível definir, por exemplo, quais servidores DNS serão utilizados pelos recursos da subrede.

8. **Gateways de Comunicação**
    - Existem diferentes _"gateways de comunicação"_ que podem ser usados no OCI. Segue resumo: <br>
        - **Internet Gateway**
            - Possibilita comunicação direta vinda da internet. Para isto, é necessário que o recurso tenha um IP público. <br><br>
        - **NAT Gateway**
            - Permite que recursos, sem endereço IP público, acessem a internet. Permite comunicação mas evita a exposição do recurso na internet. <br><br>
        - **Service Gateway**
            - Possibilita que recursos de uma subrede se comuniquem com os serviços do OCI diretamente, sem utilizar a internet. <br><br>
        - **Local Peering Gateway**
            - Possibilita conectividade entre VCNs da mesma região. <br><br>
        - **Dynamic Routing Gateway**
            - Possibilita conectividade das suas VCNs com seu ambiente on-premises, através de VPN ou FastConnect (link dedicado). <br><br>

Um dos trabalhos do arquiteto ou engenheiro cloud, é saber utilizar esses recursos para compor sua infraestrutura. Utilizaremos o desenho abaixo como guia do nosso primeiro deploy no OCI:

<br>

![alt_text](./images/oci_arch1.jpeg  "OCI - Architecture #1")

### __Decompondo o desenho em recursos Cloud__

Na cloud podemos dizer que tudo é um recurso. Um recurso possui, além de um nome, funcionalidades específicas. Para a maioria dos recursos que você cria, você tem a opção de especificar um nome para exibição. Não há regras, porém vou sugerir uma terminologia na qual eu acho útil para identificação. 

Seguindo o desenho, temos:

- **vcn-prd**: VCN de produção 10.0.0.0/16 localizada na região de São Paulo. 
<br><br>
- **subnpub_vcn-prd**: Subrede pública 10.0.5.0/24 da VCN de produção.
- **rtb_subnpub_vcn-prd**: Tabela de roteamento da subrede pública da VCN de produção.
- **secl-1_subnpub_vcn-prd**: Regras de segurança da subrede pública da VCN de produção.
- **igw_vcn-prd**: Internet Gateway da VCN de produção.
- **lb_subnpub_vcn-prd**: Load Balancer da subrede pública da VCN de produção.
<br><br>
- **subnprv-app_vcn-prd**: Subrede privada 10.0.10.0/24 para aplicação da VCN de produção.
- **rtb_subnprv-app_vcn-prd**: Tabela de roteamento da subrede privada para aplicação.
- **secl-1_subnprv-db_vcn-prd**: Regras de segurança da subrede privada para aplicação.
- **ngw_vcn-prd**: NAT Gateway da VCN de produção.
- **vm-wordpress_subnprv-app_vcn-prd**: Máquina virtual da aplicação Wordpress.
- **blk1_vm-wordpress_subnprv-app_vcn-prd**: Bloco de Disco #1 da máquina virtual da aplicação Wordpress.
<br><br> 
- **subnprv-db_vcn-prd**: Subrede privada 10.0.20.0/24 para banco de dados da VCN de produção.
- **rtb_subnprv-db_vcn-prd**: Tabela de roteamento da subrede privada para banco de dados.
- **secl-1_subnprv-db_vcn-prd**: Regras de segurança da subrede privada para banco de dados.
- **sgw_vcn-prd**: Service Gateway da VCN de produção.
- **mysql_subnprv-db_vcn-prd**: Instância MySQL da subrede privada para banco de dados.
<br><br> 
- **dhcp_vcn-prd**: DHCP Options da VCN de produção.

Antes de começarmos, vamos criar os respectivos compartimentos para abrigar os recursos:

```
suaEmpresa (root)
   ├── cmp-network   
   ├── projeto-wordpress      
   │     ├── cmp-database
   │     └── cmp-app
  ...
```

A ideia é termos grupos de usuários, com políticas de autorização, por compartimento:

| Grupo        | Descrição dos Grupos                            | Compartimento     | Descrição do Compartimento                         | 
| ------------ | ----------------------------------------------- | ----------------- | -------------------------------------------------- | 
| grp-dba      | Usuários administradores dos Bancos de Dados    | cmp-database      | Recursos de Banco de Dados da aplicação Wordpress  |
| grp-netadm   | Usuários administradores das Redes              | cmp-network       | Recursos de Redes de todo o Tenant                 |
| grp-appadm   | Usuários administradores da aplicação Wordpress | cmp-app           | Recursos da aplicação Wordpress                    |

Note que o compartimento "cmp-app" e "cmp-database" são "filhos" do compartimento pai "projeto-wordpress".

### __Compartimentos__

Primeiramente criaremos o compartimento que irá abrigar os recursos de rede:

```
darmbrust@hoodwink:~$ oci iam compartment create \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --name "cmp-network" \
> --description "Recursos de Redes de todo o Tenant"
{
  "data": {
    "compartment-id": "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-08-29T10:56:45.950Z"
      }
    },
    "description": "Recursos de Redes de todo o Tenant",
    "freeform-tags": {},
    "id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "inactive-status": null,
    "is-accessible": true,
    "lifecycle-state": "ACTIVE",
    "name": "cmp-network",
    "time-created": "2021-08-29T10:56:46.068000+00:00"
  },
  "etag": "f60c360a752af33bafb60cda00245d8974c0ba46"
}
```

Após isto, criaremos o compartimento pai "projeto-wordpress" que irá abrigar todos os recursos relacionados a aplicação:

```
darmbrust@hoodwink:~$ oci iam compartment create \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --name "projeto-wordpress" --description "Projeto Wordpress"
{
  "data": {
    "compartment-id": "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-08-20T19:08:44.763Z"
      }
    },
    "description": "Projeto Wordpress",
    "freeform-tags": {},
    "id": "ocid1.compartment.oc1..aaaaaaaagnkmm5chrzmx6agponivbwohrabrzridbvxpaomwvntlq2qehk5a",
    "inactive-status": null,
    "is-accessible": true,
    "lifecycle-state": "ACTIVE",
    "name": "projeto-wordpress",
    "time-created": "2021-08-20T19:08:44.812000+00:00"
  },
  "etag": "316130173d4b2d17074a4731ee8ba79716166ecd"
}
```

Perceba que o pai do compartimento "projeto-wordpress" e "cmp-network", é o OCID que representa o nosso Tenant. Qualquer outro compartimento criado e que for filho do "projeto-wordpress", deve utilizar o seu OCID como valor do parâmetro _"--compartment-id"_. Observe isto na criação dos próximos compartimentos:

```
darmbrust@hoodwink:~$ oci iam compartment list --query "data[?name=='projeto-wordpress'].id"
[
  "ocid1.compartment.oc1..aaaaaaaagnkmm5chrzmx6agponivbwohrabrzridbvxpaomwvntlq2qehk5a"
]
```

```
darmbrust@hoodwink:~$ oci iam compartment create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaagnkmm5chrzmx6agponivbwohrabrzridbvxpaomwvntlq2qehk5a" \
> --name "cmp-app" \
> --description "Recursos da aplicação Wordpress"
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaagnkmm5chrzmx6agponivbwohrabrzridbvxpaomwvntlq2qehk5a",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-08-29T10:53:14.922Z"
      }
    },
    "description": "Recursos da aplicação Wordpress",
    "freeform-tags": {},
    "id": "ocid1.compartment.oc1..aaaaaaaamcff6exkhvp4aq3ubxib2wf74v7cx22b3yj56jnfkazoissdzefq",
    "inactive-status": null,
    "is-accessible": true,
    "lifecycle-state": "ACTIVE",
    "name": "cmp-app",
    "time-created": "2021-08-29T10:53:15.099000+00:00"
  },
  "etag": "be12c5cb887aaaf26dfe4998c77740a90d6c3bba"
}
```

```
darmbrust@hoodwink:~$ oci iam compartment create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaagnkmm5chrzmx6agponivbwohrabrzridbvxpaomwvntlq2qehk5a" \
> --name "cmp-database" \
> --description "Recursos de Banco de Dados da aplicação Wordpress"
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaagnkmm5chrzmx6agponivbwohrabrzridbvxpaomwvntlq2qehk5a",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-08-29T11:05:32.800Z"
      }
    },
    "description": "Recursos de Banco de Dados da aplica\u00e7\u00e3o Wordpress",
    "freeform-tags": {},
    "id": "ocid1.compartment.oc1..aaaaaaaa6d2s5sgmxmyxu2vca3pn46y56xisijjyhdjwgqg3f6goh3obj4qq",
    "inactive-status": null,
    "is-accessible": true,
    "lifecycle-state": "ACTIVE",
    "name": "cmp-database",
    "time-created": "2021-08-29T11:05:32.953000+00:00"
  },
  "etag": "7113e72e6cf4dd09177f1e788c01a76a93bd2321"
}
```

>_**__NOTA:__** Recursos que fazem parte do serviço IAM, são globais. Recursos globais devem ser criados na **HOME REGION**. Utilize a opção **--region** para especificar sua **HOME REGION** caso o arquivo de configuração do OCI CLI não faça referência a ela._

### __Grupos e Políticas de Autorização__

Criaremos os grupos conforme o comando abaixo:

```
darmbrust@hoodwink:~$ oci iam group create --name "grp-dba" --description "Usuários administradores dos Bancos de Dados"
{
  "data": {
    "compartment-id": "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-08-20T20:48:05.750Z"
      }
    },
    "description": "Usu\u00e1rios administradores dos Bancos de Dados",
    "freeform-tags": {},
    "id": "ocid1.group.oc1..aaaaaaaapqaq4mp2p2yaf5yqut4vcy4i5smhiz22crwim3z363ytvwexk3ta",
    "inactive-status": null,
    "lifecycle-state": "ACTIVE",
    "name": "grp-dba",
    "time-created": "2021-08-20T20:48:05.810000+00:00"
  },
  "etag": "aaa8b6ce8732856f4ca56f901187afda837aebae"
}
```

### __Recursos de Rede__

#### VCN (Virtual Cloud Network)

Começaremos pela criação da _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ no compartimento "cmp-network":

```
darmbrust@hoodwink:~$ oci network vcn create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --cidr-blocks '["10.0.0.0/16"]' \
> --display-name "vcn-prd" \
> --is-ipv6-enabled false \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "cidr-block": "10.0.0.0/16",
    "cidr-blocks": [
      "10.0.0.0/16"
    ],
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "default-dhcp-options-id": "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaa5lhwt42vtk36f4xp6ye5aaimetxnxxnbqutydba552radfl4axnq",
    "default-route-table-id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaayjxzvc6lnwikuz2nnnre7mty5cfpdv72cvmh2iocrybq3kpmqsxa",
    "default-security-list-id": "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaauavgqje5buhc7npolmyequp72qepqod5xebjyx2u5ekc5x3lun5q",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-08-29T19:52:52.652Z"
      }
    },
    "display-name": "vcn-prd",
    "dns-label": null,
    "freeform-tags": {},
    "id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a",
    "ipv6-cidr-blocks": null,
    "lifecycle-state": "AVAILABLE",
    "time-created": "2021-08-29T19:52:52.722000+00:00",
    "vcn-domain-name": null
  },
  "etag": "31468da7"
}
```

Por padrão, uma _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ já "nasce" equipada com um _[DHCP Options](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDHCP.htm#DHCP_Options) (default-dhcp-options-id)_, uma _[Tabela de Roteamento](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingroutetables.htm#Route2) (default-route-table-id)_ e uma _[Security List](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/securitylists.htm) (default-security-list-id)_. Estes não podem ser removidos. 

Criaremos cada um desses recursos de forma separada. Você é livre para usar os recursos criados por padrão, se preferir.

#### Opções de DHCP (DHCP Options)

Para se criar o recurso _[DHCP Options](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDHCP.htm)_ é necessário informar o OCID da _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ no qual as opções de DHCP serão anexadas. Para isto, começaremos consultado qual OCID da _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ criada:

```
darmbrust@hoodwink:~$ oci network vcn list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --query 'data[?name=="vcn-prd"].id'
[
  "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a"
]
```

A partir do valor OCID da _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ criada, criaremos o _[DHCP Options](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDHCP.htm)_ com o comando abaixo:

```
darmbrust@hoodwink:~$ oci network dhcp-options create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --options '[{"type": "DomainNameServer", "serverType": "VcnLocalPlusInternet"}]' \
> --display-name "dhcp_vcn-prd" \
> --domain-name-type VCN_DOMAIN \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a" \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-08-30T14:07:12.746Z"
      }
    },
    "display-name": "dhcp_vcn-prd",
    "domain-name-type": "VCN_DOMAIN",
    "freeform-tags": {},
    "id": "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaawaku2ug5htyapopgpgvtzt5amiyalrrq2bbmczpqif7d6llbmq5q",
    "lifecycle-state": "AVAILABLE",
    "options": [
      {
        "custom-dns-servers": [],
        "server-type": "VcnLocalPlusInternet",
        "type": "DomainNameServer"
      }
    ],
    "time-created": "2021-08-30T14:07:12.842000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a"
  },
  "etag": "2261b7fb"
}
```

#### Subrede Privada - Banco de Dados
-------------------------------------

#### Service Gateway

O primeiro gateway que iremos criar é o _[Service Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/servicegateway.htm)_. Este permite que seus recursos acessem os serviços do OCI de forma segura e privada, sem precisar expor os dados à internet pública. Normalmente usamos este tipo de gateway para acessar o serviço _[Object Storage](https://docs.oracle.com/pt-br/iaas/Content/Object/Concepts/objectstorageoverview.htm)_ e possibilitar um banco de dados, por exemplo, realizar seus backups na nuvem. Este também será o nosso propósito!

>_**__NOTA:__** O [Service Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/servicegateway.htm) é um serviço regional e permite acessar somente os serviços existentes na mesma região que a VCN._

Antes de criarmos o recurso, vamos listar quais os serviços são no momento suportados de utilização pelo gateway:

```
darmbrust@hoodwink:~$ oci network service list
{
  "data": [
    {
      "cidr-block": "all-gru-services-in-oracle-services-network",
      "description": "All GRU Services In Oracle Services Network",
      "id": "ocid1.service.oc1.sa-saopaulo-1.aaaaaaaacd57uig6rzxm2qfipukbqpje2bhztqszh3aj7zk2jtvf6gvntena",
      "name": "All GRU Services In Oracle Services Network"
    },
    {
      "cidr-block": "oci-gru-objectstorage",
      "description": "OCI GRU Object Storage",
      "id": "ocid1.service.oc1.sa-saopaulo-1.aaaaaaaalrthnhiysrsux6lnhougwb2wvq37bd2tpf2au4ieahtg57zw7ura",
      "name": "OCI GRU Object Storage"
    }
  ]
}
```

No momento, temos suporte a usar todos os serviços da região _(all-gru-services-in-oracle-services-network)_ e o _[Object Storage](https://docs.oracle.com/pt-br/iaas/Content/Object/Concepts/objectstorageoverview.htm) (oci-gru-objectstorage)_.

Iremos criar o _[Service Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/servicegateway.htm)_ para utilizar especificamente o _[Object Storage](https://docs.oracle.com/pt-br/iaas/Content/Object/Concepts/objectstorageoverview.htm)_ com o comando abaixo:

```
darmbrust@hoodwink:~$ oci network service-gateway create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --services '[{"serviceId": "ocid1.service.oc1.sa-saopaulo-1.aaaaaaaalrthnhiysrsux6lnhougwb2wvq37bd2tpf2au4ieahtg57zw7ura", "serviceName": "OCI GRU Object Storage"}]' \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a" \
> --display-name "srgw_vcn-prd"
{
  "data": {
    "block-traffic": false,
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-08-30T17:16:12.619Z"
      }
    },
    "display-name": "srgw_vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.servicegateway.oc1.sa-saopaulo-1.aaaaaaaaocdhz5mzk3pu3cmkn6gfggoqig4qvwrn5mbgbvrtbyz2t2n67rqa",
    "lifecycle-state": "AVAILABLE",
    "route-table-id": null,
    "services": [
      {
        "service-id": "ocid1.service.oc1.sa-saopaulo-1.aaaaaaaalrthnhiysrsux6lnhougwb2wvq37bd2tpf2au4ieahtg57zw7ura",
        "service-name": "OCI GRU Object Storage"
      }
    ],
    "time-created": "2021-08-30T17:16:13.066000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a"
  },
  "etag": "c2b79a65"
}
```

#### Tabela de Roteamento

A _[tabela de roteamento](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingroutetables.htm)_, da subrede privada para banco de dados, só irá possuir uma regra. Esta irá direcionar o tráfego, dos recursos desta subrede, para o _[Service Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/servicegateway.htm)_ que possibilita uma comunicação segura até o _[Object Storage](https://docs.oracle.com/pt-br/iaas/Content/Object/Concepts/objectstorageoverview.htm)_. 

```
darmbrust@hoodwink:~$  oci network route-table create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --route-rules '[{"destination":"oci-gru-objectstorage", "destinationType": "SERVICE_CIDR_BLOCK", "networkEntityId": "ocid1.servicegateway.oc1.sa-saopaulo-1.aaaaaaaaocdhz5mzk3pu3cmkn6gfggoqig4qvwrn5mbgbvrtbyz2t2n67rqa"}]' \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a" \
> --display-name "rtb_subnprv-db_vcn-prd" \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-08-31T11:16:15.966Z"
      }
    },
    "display-name": "rtb_subnprv-db_vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaalq2gf3mksa27rueidzfbq677ss2bxkkvlapekjs2tt4ske6ueyna",
    "lifecycle-state": "AVAILABLE",
    "route-rules": [
      {
        "cidr-block": null,
        "description": null,
        "destination": "oci-gru-objectstorage",
        "destination-type": "SERVICE_CIDR_BLOCK",
        "network-entity-id": "ocid1.servicegateway.oc1.sa-saopaulo-1.aaaaaaaaocdhz5mzk3pu3cmkn6gfggoqig4qvwrn5mbgbvrtbyz2t2n67rqa"
      }
    ],
    "time-created": "2021-08-31T11:16:15.984000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a"
  },
  "etag": "e50a5079"
}
```

#### Security List

Para a subrede de banco de dados, iremos permitir somente tráfego de entrada na porta 3306/TCP a partir das portas clientes 1024/TCP até 65535/TCP. Isto é feito pelos parâmetros _"--egress-security-rules"_ e _"--ingress-security-rules"_, que permitem especificar regras de saída e entrada.

```
darmbrust@hoodwink:~$ oci network security-list create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --egress-security-rules '[{"destination": "0.0.0.0/0", "protocol": "all", "isStateless": true}]' \
> --ingress-security-rules '[{"source": "0.0.0.0/0", "protocol": "6", "isStateless": true, "tcpOptions": {"destinationPortRange": {"min": 3306, "max": 3306}, "sourcePortRange": {"min": 1024, "max": 65535}}}]' \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a" \
> --display-name "secl-1_subnprv-db_vcn-prd" \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-08-31T14:22:46.542Z"
      }
    },
    "display-name": "secl-1_subnprv-db_vcn-prd",
    "egress-security-rules": [
      {
        "description": null,
        "destination": "0.0.0.0/0",
        "destination-type": "CIDR_BLOCK",
        "icmp-options": null,
        "is-stateless": true,
        "protocol": "all",
        "tcp-options": null,
        "udp-options": null
      }
    ],
    "freeform-tags": {},
    "id": "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaal4rgkk7np7hoxt5cjr6topysdp4b4xrudlk4mbmvibf5knz72bgq",
    "ingress-security-rules": [
      {
        "description": null,
        "icmp-options": null,
        "is-stateless": true,
        "protocol": "6",
        "source": "0.0.0.0/0",
        "source-type": "CIDR_BLOCK",
        "tcp-options": {
          "destination-port-range": {
            "max": 3306,
            "min": 3306
          },
          "source-port-range": {
            "max": 65535,
            "min": 1024
          }
        },
        "udp-options": null
      }
    ],
    "lifecycle-state": "AVAILABLE",
    "time-created": "2021-08-31T14:22:46.587000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a"
  },
  "etag": "da35004c"
}
```

Nota-se que cada protocolo é identificado através do seu número. Na verdade, todo protocolo da pilha TCP/IP possui um número de identificação. Você pode consultar o número de cada protocolo, e sua respectiva especificação neste _[link](https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)_. 

De acordo com a documentação da API da _[Security List](https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/datatypes/IngressSecurityRule)_, os números para os protocolos suportados são:

- ICMP ("1")
- TCP ("6")
- UDP ("17")
- ICMPv6 ("58")

#### Subrede

Agora que temos os recursos básicos já criados, vamos uni-los para criarmos a subrede. Primeiramente, vamos obter o OCID dos recursos necessários:

- Opções de DHCP (DHCP Options)

```
darmbrust@hoodwink:~$ oci network dhcp-options list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --query "data [?contains(\"display-name\",'dhcp_vcn-prd')].id"
[  
  "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaawaku2ug5htyapopgpgvtzt5amiyalrrq2bbmczpqif7d6llbmq5q"
]
```

- Tabela de Roteamento

```
darmbrust@hoodwink:~$ oci network route-table list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --query "data [?contains(\"display-name\",'rtb_subnprv-db_vcn-prd')].id"
[
  "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaalq2gf3mksa27rueidzfbq677ss2bxkkvlapekjs2tt4ske6ueyna"
]
```

- Security List

```
darmbrust@hoodwink:~$ oci network security-list list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --query "data [?contains(\"display-name\",'secl-1_subnprv-db_vcn-prd')].id"
[
  "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaal4rgkk7np7hoxt5cjr6topysdp4b4xrudlk4mbmvibf5knz72bgq"
]
```

A partir do OCID de cada um dos recursos, criaremos a subrede com o comando abaixo:

```
darmbrust@hoodwink:~$ oci network subnet create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a" \
> --dhcp-options-id "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaawaku2ug5htyapopgpgvtzt5amiyalrrq2bbmczpqif7d6llbmq5q" \
> --route-table-id "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaalq2gf3mksa27rueidzfbq677ss2bxkkvlapekjs2tt4ske6ueyna" \
> --security-list-ids '["ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaal4rgkk7np7hoxt5cjr6topysdp4b4xrudlk4mbmvibf5knz72bgq"]' \
> --display-name "subnprv-db_vcn-prd" \
> --cidr-block "10.0.20.0/24" \
> --prohibit-public-ip-on-vnic true \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "availability-domain": null,
    "cidr-block": "10.0.20.0/24",
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-01T11:28:03.526Z"
      }
    },
    "dhcp-options-id": "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaawaku2ug5htyapopgpgvtzt5amiyalrrq2bbmczpqif7d6llbmq5q",
    "display-name": "subnprv-db_vcn-prd",
    "dns-label": null,
    "freeform-tags": {},
    "id": "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaagyg2sk2c4j46ky3lngceejohdzswlffsavqqybepekbean3gytba",
    "ipv6-cidr-block": null,
    "ipv6-virtual-router-ip": null,
    "lifecycle-state": "AVAILABLE",
    "prohibit-internet-ingress": true,
    "prohibit-public-ip-on-vnic": true,
    "route-table-id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaalq2gf3mksa27rueidzfbq677ss2bxkkvlapekjs2tt4ske6ueyna",
    "security-list-ids": [
      "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaal4rgkk7np7hoxt5cjr6topysdp4b4xrudlk4mbmvibf5knz72bgq"
    ],
    "subnet-domain-name": null,
    "time-created": "2021-09-01T11:28:03.776000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a",
    "virtual-router-ip": "10.0.20.1",
    "virtual-router-mac": "00:00:17:96:B4:D5"
  },
  "etag": "dc5d4c74"
}
```

Alguns parâmetros que destaco serem importantes quando criamos uma subrede. O parâmetro _"--prohibit-public-ip-on-vnic"_ define se uma subrede é pública ou privada. Se uma subrede permite endereço IP público em uma VNIC, ela é caracterizada como sendo uma _"subrede pública"_ (aceita tráfego da internet). Neste caso, definimos o valor como _"true"_, que impede as VNICs da subrede de terem endereço IP público. Como efeito disto, a subrede se torna privada.

Um outro detalhe é referente a _[Security List](https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/datatypes/IngressSecurityRule)_. Perceba que o tipo de dado do parâmetro _"--security-list-ids"_ é um vetor. Ou seja, é possível definir várias listas de segurança sendo que cada lista pode ter várias regras. Um pacote de dados será permitido se qualquer regra, em qualquer uma das listas possibilitar o tráfego. 

#### Subrede Privada - Aplicação Wordpress
------------------------------------------

#### NAT Gateway

O _[NAT Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/NATgateway.htm)_ permite que os recursos da subrede privada acessem a internet. Normalmente estes recursos utilizam o _[NAT Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/NATgateway.htm)_ para executar atualizações via internet (ex: yum / Windows Update).

Para criarmos o _[NAT Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/NATgateway.htm)_ usamos o comando abaixo:

```
darmbrust@hoodwink:~$ oci network nat-gateway create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a" \
> --block-traffic false \
> --display-name "ntgw_vcn-prd" \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "block-traffic": false,
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-01T14:35:28.931Z"
      }
    },
    "display-name": "ntgw_vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.natgateway.oc1.sa-saopaulo-1.aaaaaaaazgfctgpxk76ofiernbtx66aiusmgal3c3gkbn2r6smqmorvyv4ea",
    "lifecycle-state": "AVAILABLE",
    "nat-ip": "150.230.78.168",
    "public-ip-id": "ocid1.publicip.oc1.sa-saopaulo-1.aaaaaaaaqahv2uzjlbb5ngwal2icgodzpsvx7nfbt4fxxkshz43cwkcpwx5a",
    "time-created": "2021-09-01T14:35:29.328000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a"
  },
  "etag": "63069701"
}
```

Como os recursos, VNICs para ser mais específico, da subrede privada não possuem endereço IP público, eles utilizam o endereço IP do _[NAT Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/NATgateway.htm)_ para conectividade com a Internet. Esta conectividade é feita através de uma técnica chamada _[Network Address Translation](https://pt.wikipedia.org/wiki/Network_address_translation)_. 

Perceba que na saída do comando que criou o _[NAT Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/NATgateway.htm)_, é possível ver o IP público que este irá usar em _"nat-ip"_. De qualquer forma, também é possível consultar as propriedades deste IP público pelo OCID contido em _"public-ip-id"_:

```
darmbrust@hoodwink:~$ oci network public-ip get \
> --public-ip-id "ocid1.publicip.oc1.sa-saopaulo-1.aaaaaaaaqahv2uzjlbb5ngwal2icgodzpsvx7nfbt4fxxkshz43cwkcpwx5a"
{
  "data": {
    "assigned-entity-id": "ocid1.natgateway.oc1.sa-saopaulo-1.aaaaaaaazgfctgpxk76ofiernbtx66aiusmgal3c3gkbn2r6smqmorvyv4ea",
    "assigned-entity-type": "NAT_GATEWAY",
    "availability-domain": null,
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-01T14:35:30.314Z"
      }
    },
    "display-name": "IP for NAT gateway: ocid1.natgateway.oc1.sa-saopaulo-1.aaaaaaaazgfctgpxk76ofiernbtx66aiusmgal3c3gkbn2r6smqmorvyv4ea",
    "freeform-tags": {},
    "id": "ocid1.publicip.oc1.sa-saopaulo-1.aaaaaaaaqahv2uzjlbb5ngwal2icgodzpsvx7nfbt4fxxkshz43cwkcpwx5a",
    "ip-address": "150.230.78.168",
    "lifecycle-state": "ASSIGNED",
    "lifetime": "EPHEMERAL",
    "private-ip-id": null,
    "public-ip-pool-id": null,
    "scope": "REGION",
    "time-created": "2021-09-01T14:35:30.439000+00:00"
  },
  "etag": "3a8d891"
}
```

A última opção que quero mostrar aqui, é a possibilidade de bloquear a passagem de tráfego pelo _[NAT Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/NATgateway.htm)_. Usa-se esta opção, quando queremos temporariamente impedir a comunicação dos recursos da subrede privada com a internet:

```
darmbrust@hoodwink:~$ oci network nat-gateway update \
> --nat-gateway-id "ocid1.natgateway.oc1.sa-saopaulo-1.aaaaaaaazgfctgpxk76ofiernbtx66aiusmgal3c3gkbn2r6smqmorvyv4ea" \
> --block-traffic true
{
  "data": {
    "block-traffic": true,
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-01T14:35:28.931Z"
      }
    },
    "display-name": "ntgw_vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.natgateway.oc1.sa-saopaulo-1.aaaaaaaazgfctgpxk76ofiernbtx66aiusmgal3c3gkbn2r6smqmorvyv4ea",
    "lifecycle-state": "AVAILABLE",
    "nat-ip": "150.230.78.168",
    "public-ip-id": "ocid1.publicip.oc1.sa-saopaulo-1.aaaaaaaaqahv2uzjlbb5ngwal2icgodzpsvx7nfbt4fxxkshz43cwkcpwx5a",
    "time-created": "2021-09-01T14:35:29.328000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a"
  },
  "etag": "63069701"
}
```

#### Tabela de Roteamento

A _[tabela de roteamento](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingroutetables.htm)_ da subrede privada para a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_, também só irá possuir uma regra. Esta irá direcionar o tráfego para o _[NAT Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/NATgateway.htm)_ que criamos.

```
darmbrust@hoodwink:~$ oci network route-table create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --route-rules '[{"destination":"0.0.0.0/0", "destinationType": "CIDR_BLOCK", "networkEntityId": "ocid1.natgateway.oc1.sa-saopaulo-1.aaaaaaaazgfctgpxk76ofiernbtx66aiusmgal3c3gkbn2r6smqmorvyv4ea"}]' \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a" \
> --display-name "rtb_subnprv-app_vcn-prd" \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaaie4exnvj2ktkjlliahl2bxmdnteu2xmn27oc5cy5mdcmocl4vd7q",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-01T17:58:14.413Z"
      }
    },
    "display-name": "rtb_subnprv-app_vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaaswshtzo7i2ad5bxj5ewqa6vfp2tziyrg7y7leudmxaerp3mihhka",
    "lifecycle-state": "AVAILABLE",
    "route-rules": [
      {
        "cidr-block": null,
        "description": null,
        "destination": "0.0.0.0/0",
        "destination-type": "CIDR_BLOCK",
        "network-entity-id": "ocid1.natgateway.oc1.sa-saopaulo-1.aaaaaaaazgfctgpxk76ofiernbtx66aiusmgal3c3gkbn2r6smqmorvyv4ea"
      }
    ],
    "time-created": "2021-09-01T17:58:14.483000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qayteedpos5f43koooqrkmks6de2r44w7kn62uxlk6c2ka"
  },
  "etag": "e6a27cac"
}
```

#### Security List

Para a subrede da aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_, iremos permitir _"tráfego total"_:

```
darmbrust@hoodwink:~$ oci network security-list create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --egress-security-rules '[{"destination": "0.0.0.0/0", "protocol": "all", "isStateless": true}]' \
> --ingress-security-rules '[{"source": "0.0.0.0/0", "protocol": "all", "isStateless": true}]' \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a" \
> --display-name "secl-1_subnprv-app_vcn-prd" \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-01T19:27:24.352Z"
      }
    },
    "display-name": "secl-1_subnprv-app_vcn-prd",
    "egress-security-rules": [
      {
        "description": null,
        "destination": "0.0.0.0/0",
        "destination-type": "CIDR_BLOCK",
        "icmp-options": null,
        "is-stateless": true,
        "protocol": "all",
        "tcp-options": null,
        "udp-options": null
      }
    ],
    "freeform-tags": {},
    "id": "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaacsbcnmseb2v7flq7guqmee4fuij3d4rhldftqyneingvmre6sqzq",
    "ingress-security-rules": [
      {
        "description": null,
        "icmp-options": null,
        "is-stateless": true,
        "protocol": "all",
        "source": "0.0.0.0/0",
        "source-type": "CIDR_BLOCK",
        "tcp-options": null,
        "udp-options": null
      }
    ],
    "lifecycle-state": "AVAILABLE",
    "time-created": "2021-09-01T19:27:24.533000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a"
  },
  "etag": "8f0077c4"
}
```

>_**__NOTA:__** Permitir "tráfego total" não é uma boa prática de segurança. O intuíto aqui é mostrar as possibilidades dos parâmetros do OCI CLI. Permita tráfego somente para as portas que são necessárias para o funcionamento da sua aplicação._

#### Subrede

Recursos da subrede de aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_ criados. Agora é hora de uni-los e criarmos a subrede:

```
darmbrust@hoodwink:~$ oci network subnet create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a" \
> --dhcp-options-id "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaasmnmnum6hatkw5peobjbpxeemrjherqjbbyuzvr5p7anzkhixnjq" \
> --route-table-id "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaaswshtzo7i2ad5bxj5ewqa6vfp2tziyrg7y7leudmxaerp3mihhka" \
> --security-list-ids '["ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaacsbcnmseb2v7flq7guqmee4fuij3d4rhldftqyneingvmre6sqzq"]' \
> --display-name "subnprv-app_vcn-prd" \
> --cidr-block "10.0.10.0/24" \
> --prohibit-public-ip-on-vnic true 
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "availability-domain": null,
    "cidr-block": "10.0.10.0/24",
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-02T11:50:06.781Z"
      }
    },
    "dhcp-options-id": "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaasmnmnum6hatkw5peobjbpxeemrjherqjbbyuzvr5p7anzkhixnjq",
    "display-name": "subnprv-app_vcn-prd",
    "dns-label": null,
    "freeform-tags": {},
    "id": "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaajb4wma763mz6uowun3pfeltobe4fmiegdeyma5ehvnf3kzy3jvxa",
    "ipv6-cidr-block": null,
    "ipv6-virtual-router-ip": null,
    "lifecycle-state": "AVAILABLE",
    "prohibit-internet-ingress": true,
    "prohibit-public-ip-on-vnic": true,
    "route-table-id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaaswshtzo7i2ad5bxj5ewqa6vfp2tziyrg7y7leudmxaerp3mihhka",
    "security-list-ids": [
      "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaacsbcnmseb2v7flq7guqmee4fuij3d4rhldftqyneingvmre6sqzq"
    ],
    "subnet-domain-name": null,
    "time-created": "2021-09-02T11:50:06.873000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a",
    "virtual-router-ip": "10.0.10.1",
    "virtual-router-mac": "00:00:17:96:B4:D5"
  },
  "etag": "fcb85179"
}
```

#### Subrede Pública
--------------------

#### Internet Gateway

O _[Internet Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingIGs.htm#Internet_Gateway)_ é um roteador virtual, usado exclusivamente pela subrede pública que você pode adicionar à sua VCN para permitir conectividade direta com a internet (tráfego de entrada e saída). Falando de conectividade, para que um recurso seja exposto na internet, ele obrigatóriamente deve ter um endereço IP público e residir em uma subrede pública, com sua tabela de roteamento devidamente configurada para utilizar o _[Internet Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingIGs.htm#Internet_Gateway)_.

Para criar o _[Internet Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingIGs.htm#Internet_Gateway)_ usamos o comando abaixo:

```
darmbrust@hoodwink:~$ oci network internet-gateway create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --is-enabled true \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a" \
> --display-name "igw_vcn-prd" \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-02T12:32:55.290Z"
      }
    },
    "display-name": "igw_vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.internetgateway.oc1.sa-saopaulo-1.aaaaaaaaivwrgb3iw5aupizbglwsymbluqvsc76ym7pqbjghqie32joemvoq",
    "is-enabled": true,
    "lifecycle-state": "AVAILABLE",
    "time-created": "2021-09-02T12:32:55.331000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a"
  },
  "etag": "188b383d"
}
```

Permitir ou não a passagem de tráfego pelo _[Internet Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingIGs.htm#Internet_Gateway)_, é controlado pelo parâmetro _"--is-enabled"_. 

#### Tabela de Roteamento

A _[tabela de roteamento](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingroutetables.htm)_ da subrede pública só irá possuir uma regra que direciona o tráfego para o _[Internet Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingIGs.htm#Internet_Gateway)_ que foi criado.

```
darmbrust@hoodwink:~$ oci network route-table create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --route-rules '[{"destination":"0.0.0.0/0", "destinationType": "CIDR_BLOCK", "networkEntityId": "ocid1.internetgateway.oc1.sa-saopaulo-1.aaaaaaaaivwrgb3iw5aupizbglwsymbluqvsc76ym7pqbjghqie32joemvoq"}]' \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a" \
> --display-name "rtb_subnpub_vcn-prd" \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-02T13:26:03.971Z"
      }
    },
    "display-name": "rtb_subnpub_vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaa3dmhfpagrvmj3pcararg7yir4vbmcs25inm44nmm37y7ozvdbi3q",
    "lifecycle-state": "AVAILABLE",
    "route-rules": [
      {
        "cidr-block": null,
        "description": null,
        "destination": "0.0.0.0/0",
        "destination-type": "CIDR_BLOCK",
        "network-entity-id": "ocid1.internetgateway.oc1.sa-saopaulo-1.aaaaaaaaivwrgb3iw5aupizbglwsymbluqvsc76ym7pqbjghqie32joemvoq"
      }
    ],
    "time-created": "2021-09-02T13:26:03.995000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a"
  },
  "etag": "4263d87e"
}
```

>_**__NOTA:__** O valor 0.0.0.0/0 corresponde a “Rota Padrão” (default route). Para maiores detalhes, consulte a definição [aqui](https://en.wikipedia.org/wiki/Default_route)._

#### Security List

#### Subrede