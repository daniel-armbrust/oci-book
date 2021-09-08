# Capítulo 4: Primeira aplicação no OCI

## 4.2 - Fundamentos do Serviço de Computação

### __Visão Geral__

O _[Serviço de Computação](https://docs.oracle.com/pt-br/iaas/Content/Compute/Concepts/computeoverview.htm)_ permite criar e gerenciar hosts de computação, conhecidos como **instâncias**. Uma _instância de computação_ deve obrigatóriamente ser criada e residir em um _"[Dominio de Disponibilidade (Availability Domains ou AD)](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm#top)"_, e pode ser uma **_Máquina Virtual (VM ou Virtual Machine)_** ou uma **_Máquina Física (BM ou Bare Metal)_**. 

>_**__NOTA:__** Tecnicamente falando, uma instância de computação é criada sobre um "[Domínios de Falha (Fault Domains ou FD)](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm#fault)"._

Uma instância _Bare Metal (BM)_ concede acesso a um servidor físico e dedicado, de altíssimo desempenho e sem um _[hipervisor](https://pt.wikipedia.org/wiki/Hipervisor)_. Neste modelo, além de não ser preciso compartilhar a máquina física, você tem acessos e controles exclusivos sobre a CPU, memória e placa de rede (NIC) da máquina. É como se fosse um hardware em execução no seu próprio data center, semelhante a uma ação de "_[colocation](https://pt.wikipedia.org/wiki/Colocation)_".

Já uma _Máquina Virtual (VM)_ é executada através de técnicas de _[virtualização](https://pt.wikipedia.org/wiki/Virtualiza%C3%A7%C3%A3o)_, que possibilita diferentes máquinas coexistirem, de forma isolada, sobre um hardware físico (um computador maior).

![alt_text](./images/ch4_4-2_bm-vs-vm.jpg  "Bare Metal vs. Virtual Machine")

>_**__NOTA:__** Um software que pode ser usado para criar máquinas virtuais é o [VirtualBox](https://www.virtualbox.org/). Para saber mais, consulte este [link aqui](https://www.virtualbox.org/)._

Um outro tipo de _instância de computação_ existente no OCI é o _[Dedicated Virtual Machine Host](https://docs.oracle.com/pt-br/iaas/Content/Compute/Concepts/dedicatedvmhosts.htm)_. Basicamente, este é um _Bare Metal_ dedicado ao seu uso, no qual você pode criar e executar máquinas virtuais (vm) sobre ele.

Utilizar uma _Máquina Virtual_ ou _Bare Metal_, seja de forma direta ou para criar máquinas virtuais sobre, vai depender muito da sua necessidade. Normalmente, utilizamos hardware dedicado e que não sejam compartilhado com outros clientes (único tenant), quando há algum requisito de conformidade e isolamento a cumprir, que o impedem de usar uma infraestrutura compartilhada. Porém, o mais comum de ser visto, são as máquinas virtuais (multitenancy).

Ao se cria uma instância, existem duas escolhas fundamentais a serem feitas. São elas:

- **Shape**
- **Imagem**

### __Shape__

_[Shape](https://docs.oracle.com/pt-br/iaas/Content/Compute/Concepts/computeoverview.htm#instance-types__shapes)_ ou modelo, são características que determinam a quantidade de CPUs, quantidade de memória, banda máxima da rede, total de VNICs, tipo de armazenamento suportado (NVMe ou disco convencional) e outros recursos que sua _instância de computação_ terá. Podemos dizer que o shape especifica um conjunto pré-definido de recursos. Ele especifica o perfil do hardware de computação.

>_**__NOTA:__** A quantidade de VNICs que um determinado shape suporta, tem relação também com o sistema operacional. Seja Linux ou Windows, esta quantidade máxima é diferente. Consulta este [link](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/computeshapes.htm#Compute_Shapes) para maiores detalhes._

Um shape também especifica o tipo do processador, que pode ser _[Intel](https://pt.wikipedia.org/wiki/Intel)_, _[AMD](https://pt.wikipedia.org/wiki/Advanced_Micro_Devices)_ ou processadores _[ARM](https://pt.wikipedia.org/wiki/Arquitetura_ARM)_.

Além do tipo do processador, um shape pode ter recursos fixos e otimizados especificamente para determinadas cargas de trabalho, ou ser _[flexível](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/computeshapes.htm#flexible)_.

Vamos os detalhes ...

#### __Shapes Fixos e/ou Otimizados__

Um shape pode ter recursos fixos, como quantidade de CPUs e memória, além de ser específico para executar cargas de trabalho específicas.

Dependendo das necessidades da aplicação que será executada, é possível escolher um tipo de shape computacional específico. Sendo eles:

- **Standard**
    - Projetado para atender cargas de trabalho de propósito geral. 
    
- **DenseIO**
    - Projetado para bancos de dados de grande porte, big data e aplicações que exigem storage de alto desempenho (SSDs baseadas em NVMe).

- **GPU Shapes**
    - São shapes equipados com processadores gráficos (GPU) da NVIDIA e projetados para cargas de trabalho que necessitam de aceleração em hardware.

- **High performance computing (HPC)**
    - Projetado para atender computação de alto desempenho, que exigem processadores com núcleos de alta frequência, baixa latência, redes em cluster para processamento massivo e paralelo.

- **Optimized Shapes**
    - Projetado para atender computação de alto desempenho, que exigem processadores com núcleos de alta frequência. Também podem ser usados para cargas de trabalho HPC (High performance computing).

Um shape de recursos fixos, pode ser uma _máquina virtual_ ou _bare metal_, e pode estar equipado com processador _[Intel](https://pt.wikipedia.org/wiki/Intel)_, _[AMD](https://pt.wikipedia.org/wiki/Advanced_Micro_Devices)_ ou processadores do tipo _[ARM](https://pt.wikipedia.org/wiki/Arquitetura_ARM)_ (arquitetura RISC).

Como há muitos diferentes tipos de shapes, novos são adicionados e antigos removidos, não convém colocar uma lista deles aqui. Sempre que precisar consultar quais os shapes disponíveis, verifique a lista neste _[link aqui](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/computeshapes.htm)_. É o melhor caminho.

O que vale documentar, é a forma como podemos ler a definição de um shape. Veja a sintaxe:

```
<BM|VM>.<Tipo do Shape>[Geração].[Tipo do Processador][.Qtde de CPU][.Flex|.Micro]
```

- **BM** especifica um shape como sendo _Bare Metal (BM)_, e **VM** especifica uma _Máquina Virtual (VM)_.
- **Tipo do Shape** pode ser um dos valores: _Standard_, _DenseIO_, _GPU_, _HPC_ ou _Optimized_.
- **Geração** do processador. Alguns shapes que evoluíram de uma geração anterior, apresentam um número aqui (ex: Standard1 e Standard2).
- **Tipo do Processador** pode ser _[Intel](https://pt.wikipedia.org/wiki/Intel)_, _[AMD](https://pt.wikipedia.org/wiki/Advanced_Micro_Devices)_ (E2, E3 ou E4) ou _[ARM](https://pt.wikipedia.org/wiki/Arquitetura_ARM)_ (A1). Processadores _[Intel](https://pt.wikipedia.org/wiki/Intel)_ não possuem identificação através de sigla.
- **Qtde de CPU** especifica a quantidade de CPUs do shape. Shapes flexíveis não possuem este valor, pois sua quantidade de CPU não é fixa.
- **Flex ou Micro** especifica se o shape possui características _flexíveis (Flex)_ de CPU, ou se ele é do tipo _micro_ que faz parte do programa _[Always Free](https://docs.oracle.com/pt-br/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)_.

Por exemplo:

- **VM.Standard2.2**
    - É uma _máquina virtual (VM)_ de segunda geração, equipada com processador _[Intel](https://pt.wikipedia.org/wiki/Intel)_, para cargas de trabalho de propósito geral (Standard), com duas CPUs.

- **VM.Standard.E4**
    - É uma _máquina virtual (VM)_, equipada com processador _[AMD EPYC](https://pt.wikipedia.org/wiki/EPYC)_.

- **BM.GPU3**
    - É um _bare metal (BM)_, equipado com processadores gráficos (GPU) da NVIDIA.

- **BM.Optimized3.36**
    - É um _bare metal (BM)_ de terceira geração, equipado com processador _[Intel](https://pt.wikipedia.org/wiki/Intel)_, para cargas de trabalho HPC e de alto desempenho, com 36 CPUs.

>_**__NOTA:__** Shapes de computação mudam com frequência. Para saber mais e quais shapes estão disponíveis hoje, consulte a documentação oficial neste [link aqui](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/computeshapes.htm). Alguns shapes de [geração anterior](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/computeshapes.htm#previous-generation-shapes) ainda estão disponíveis para uso, poém são mais caros e possuem desempenho inferior. Shapes antigos podem ser consultados neste [link aqui](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/computeshapes.htm#previous-generation-shapes)._


#### __Shapes Flexíveis__

O _[Shape Flexível](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/computeshapes.htm#flexible)_ permite definir qual é a quantidade de CPUs e memória alocados para a instância. A largura de banda da rede e a quantidade máxima de VNICs, é proporcional ao número de CPUs. Quanto mais CPUs, maior é a largura de banda da rede. 

Lembrando que você pode modificar a quantidade de CPU e memória, a qualquer momento após a criação da instância. Um outro detalhe é que não existe _bare metal (BM)_ em forma flexível.

_[Shapes Flexíveis](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/computeshapes.htm#flexible)_ concedem respostas rápidas sobre necessidades diferentes de desempenho, de acordo com mudanças nas cargas de trabalho.

Por exemplo:

- **VM.Standard.E4.Flex**
    - É uma _máquina virtual (VM)_, equipada com processador _[AMD EPYC](https://pt.wikipedia.org/wiki/EPYC)_, flexível na definição da quantidade de CPU e memória. 

- **VM.Standard.A1.Flex**
    - É uma _máquina virtual (VM)_, equipada com processador _[ARM Ampere Altra](https://en.wikipedia.org/wiki/Ampere_Computing)_, flexível na definição da quantidade de CPU e memória.

 >_**__NOTA:__** A quantidade de memória permitida é baseada no número de CPU que foi selecionado. Esta proporção também depende do tipo do shape. Consulte detalhes na documentação oficial [aqui](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/computeshapes.htm#flexible)._

#### __Listando Shapes Disponíveis__

Para verificar a lista de shapes disponíveis para uso em determinada região, usamos o comando abaixo:

```
darmbrust@hoodwink:~$ oci compute shape list \
> --region sa-saopaulo-1 \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --query "data[].{shape:shape,ocpus:ocpus,\"memory-in-gbs\":\"memory-in-gbs\"}" \
> --all \
> --output table
+---------------+-------+---------------------+
| memory-in-gbs | ocpus | shape               |
+---------------+-------+---------------------+
| 1024.0        | 160.0 | BM.Standard.A1.160  |
| 768.0         | 52.0  | BM.Standard2.52     |
| 512.0         | 36.0  | BM.Optimized3.36    |
| 2048.0        | 128.0 | BM.Standard.E4.128  |
| 2048.0        | 128.0 | BM.Standard.E3.128  |
| 512.0         | 64.0  | BM.Standard.E2.64   |
| 768.0         | 52.0  | BM.DenseIO2.52      |
| 14.0          | 1.0   | VM.Optimized3.Flex  |
| 16.0          | 1.0   | VM.Standard.E4.Flex |
| 16.0          | 1.0   | VM.Standard.E3.Flex |
| 6.0           | 1.0   | VM.Standard.A1.Flex |
| 15.0          | 1.0   | VM.Standard2.1      |
| 30.0          | 2.0   | VM.Standard2.2      |
| 60.0          | 4.0   | VM.Standard2.4      |
| 120.0         | 8.0   | VM.Standard2.8      |
| 240.0         | 16.0  | VM.Standard2.16     |
| 320.0         | 24.0  | VM.Standard2.24     |
| 8.0           | 1.0   | VM.Standard.E2.1    |
| 16.0          | 2.0   | VM.Standard.E2.2    |
| 32.0          | 4.0   | VM.Standard.E2.4    |
| 64.0          | 8.0   | VM.Standard.E2.8    |
| 120.0         | 8.0   | VM.DenseIO2.8       |
| 240.0         | 16.0  | VM.DenseIO2.16      |
| 320.0         | 24.0  | VM.DenseIO2.24      |
+---------------+-------+---------------------+
```

### Imagem

O outro item necessário para se criar uma instância de computação está na escolha de uma _[imagem](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images)_. Uma _[imagem](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images)_ é um template que especifica o sistema operacional e qualquer outro software pré-instalado, que uma instância irá utilizar.

Toda _[imagem](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images)_ utiliza um pequeno disco chamado _[boot volume](https://docs.oracle.com/pt-br/iaas/Content/Block/Concepts/bootvolumes.htm)_ ou disco de inicialização. Este é criado e associado a instância no momento da sua criação. Ele abriga o sistema operacional, além do _[boot loader](https://en.wikipedia.org/wiki/Bootloader)_ necessário para boot da instância.

Para instâncias que utilizam sistema operacional Linux, o _[boot volume](https://docs.oracle.com/pt-br/iaas/Content/Block/Concepts/bootvolumes.htm)_ "nasce" com **50 GB** de tamanho. Já para o sistema operacional Windows, este valor é de **256 GB**. Porém, é possível termos um _[boot volume](https://docs.oracle.com/pt-br/iaas/Content/Block/Concepts/bootvolumes.htm)_ de até **32 TB** para ambos os sistemas operacionais. Mais detalhes, você encontra neste _[link aqui](https://docs.oracle.com/pt-br/iaas/Content/Block/Concepts/bootvolumes.htm#Custom)_.

>_**__NOTA:__** Tecnicamente falando, quando você cria uma instância usando uma [imagem de plataforma](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images) ou uma [imagem personalizada](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/managingcustomimages.htm#Managing_Custom_Images), um [boot volume](https://docs.oracle.com/pt-br/iaas/Content/Block/Concepts/bootvolumes.htm) é criado para abrigar o sistema operacional da [imagem](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images) no mesmo compartimento. Um [boot volume](https://docs.oracle.com/pt-br/iaas/Content/Block/Concepts/bootvolumes.htm) não está associado a uma [imagem](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images). É a [imagem](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images) que possui instruções para criar um [boot volume](https://docs.oracle.com/pt-br/iaas/Content/Block/Concepts/bootvolumes.htm) necessário para o sistema operacional dela._

Quando criamos uma instância, podemos escolher uma entre as diversas categorias que diponibilizam uma _[imagem](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images)_ para utilização:

- **Imagens de Plataforma**
    - O OCI disponibiliza diferentes _[imagem](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images)_ de diferentes versões dos sistemas operacionais, Linux e Windows, mais conhecidos.
    - A extensa lista pode ser consultada neste _[link aqui](https://docs.oracle.com/en-us/iaas/images/)_.
    
- **Imagens Personalizadas**
    - É uma _[imagem](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images)_ que você criou, alterou e mantém guardada no OCI para iniciar outras intâncias. 
    
- **BYOI (Bring Your Own Image)**
    - O recurso _[BYOI (Bring Your Own Image)](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/bringyourownimage.htm)_ permite que você traga suas próprias versões de sistemas operacionais para o OCI.
    - Este tipo de recurso também é útil, quando se deseja trazer para a nuvem (lift-and-shift), um sistema operacional antigo e que não está mais disponível (legado).
    - Neste modelo, esteja atento referente aos _"requisitos de licenciamento"_ no qual você deve cumprir, se aplicável. Lembrando que o OCI não "absorve" sua licença.

- **Marketplace**
    - O serviço _[Marketplace](https://cloudmarketplace.oracle.com/marketplace/oci)_ do OCI disponibiliza várias _[imagem](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images)_ já prontas pro uso. 
    - Estas _[imagens](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images)_ incluem softwares pré-instalados da própria Oracle e de outros parceiros, como: Microsoft SQL Server, Oracle WebLogic, FortiGate Firewall, SUSE Linux, entre outros.
    - Podem haver situações em que utilizar uma imagem do _[marketplace](https://cloudmarketplace.oracle.com/marketplace/oci)_, pode ser necessário adquirir licenciamento extra, diretamente com o fabricante da imagem. 

Para listarmos todas as _imagens de plataforma_ da região _sa-saopaulo-1_ que temos disponíveis, usamos o comando abaixo:

```
darmbrust@hoodwink:~$ oci compute image list \
> --region sa-saopaulo-1 \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --query "data[].{Name:\"display-name\",OCID:id}" \
> --output table \
> --sort-order ASC \
> --all
+-----------------------------------------------+--------------------------------------------------------------------------------------------+
| Name                                          | OCID                                                                                       |
+-----------------------------------------------+--------------------------------------------------------------------------------------------+
| Canonical-Ubuntu-18.04-2021.07.16-0           | ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa74nz3eo5oqeaoqjiiwukncim6rjzgufwqarioewmusmra7tmq7qq |
| Canonical-Ubuntu-18.04-2021.08.25-0           | ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa22q64w6qge3imhnv3nwnnflf255mrpvhzv4dg7ztagk27hdqxtqa |
| Canonical-Ubuntu-18.04-Minimal-2021.06.11-0   | ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa45dvzfzast6nn5yhfh4scvwbaet2fjl4espgyfly4xgyxtuocngq |
| Canonical-Ubuntu-18.04-Minimal-2021.07.16-0   | ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaqiorzyhfzo62nxyzivlejudxrtjuahmcdnctfogr4sszukstilea |
| Canonical-Ubuntu-18.04-Minimal-2021.08.27-0   | ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaz6gbwjn2n5qolrrrnu3vslwsjo5bn2fkpphocr24fgetbgu4fljq |
...
```

O resultado do comando foi truncado para não ocupar muito espaço de tela. 

### __Instância da aplicação Wordpress__

Já estudamos o básico sobre shape e imagem. Agora é hora de criarmos nossa primeira instância para hospedar o _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_. Antes de mais nada, precisamos de algumas informações em mãos, para preencher alguns parâmetros obrigatórios do comando que irá criar a instância.

#### __Compartimento__

Sabemos que o compartimento criado para hospedar nossa instância possui o nome _"cmp-app"_. Através do comando abaixo, é possível obter o valor do seu id:

```
darmbrust@hoodwink:~$ oci iam compartment list --compartment-id-in-subtree true --name "cmp-app" --query "data[].id"
[
  "ocid1.compartment.oc1..aaaaaaaamcff6exkhvp4aq3ubxib2wf74v7cx22b3yj56jnfkazoissdzefq"
]
```

#### __Dominio de Disponibilidade (Availability Domains ou AD)__

Agora, precisamos saber qual é o nome do _"[Dominio de Disponibilidade](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm#top)"_ da região que criaremos a instância. Lembrando que existem regiões que possuem mais de um _"[Dominio de Disponibilidade](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm#top)"_.

Para listarmos o nome de todos os _"[Dominios de Disponibilidade](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm#top)"_ de uma região, disponíveis em nosso _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_, usamos o comando abaixo:

```
darmbrust@hoodwink:~$ oci iam availability-domain list \
> --region sa-saopaulo-1 \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --all \
> --query "data[].name"
[
  "ynrK:SA-SAOPAULO-1-AD-1"
]
```

#### __Shape e Imagem__

Para o nosso exemplo, iremos utilizar o shape "VM.Standard2.2" com "Oracle Linux 7.9". A partir dessas informações, é possível obter quais _[imagens](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images)_ são compatíveis com este shape, e que estão disponíveis pra uso em nosso _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_.

Com o comando abaixo, iremos obter o OCID da _[imagem](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images)_ mais recente, como primeiro item da tabela.

```
darmbrust@hoodwink:~$ oci compute image list --region sa-saopaulo-1 \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --operating-system "Oracle Linux" \
> --operating-system-version "7.9" \
> --shape "VM.Standard2.2" \
> --lifecycle-state "AVAILABLE" \
> --sort-by TIMECREATED \
> --all \
> --query "data[].[\"display-name\",id]" \
> --output table
+-------------------------------+--------------------------------------------------------------------------------------------+
| Column1                       | Column2                                                                                    |
+-------------------------------+--------------------------------------------------------------------------------------------+
| Oracle-Linux-7.9-2021.08.27-0 | ocid1.image.oc1.sa-saopaulo-1.aaaaaaaasahnls6nmev22raz7ecw6i64d65fu27pmqjn4pgz7zue56ojj7qq |
| Oracle-Linux-7.9-2021.07.27-0 | ocid1.image.oc1.sa-saopaulo-1.aaaaaaaafi7s3mg6pobem2j3cb7tyvnibijb657fzjvmsdtodsg54mli4jfa |
| Oracle-Linux-7.9-2021.06.20-0 | ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa4vkhemdkmfe3icxzzdkgfnfijybzzhrz63icerlq7oyzdoe3mv6a |
+-------------------------------+--------------------------------------------------------------------------------------------+
```

Neste caso, usaremos a _[imagem](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images)_ disponível no OCI (imagem de plataforma) do sistema operacional "Oracle Linux 7.9", construída na data de 27/08/2021.

#### __Chave SSH__

Instâncias Linux, criadas a partir de imagens de plataforma, utilizam _[chaves SSH](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/managingkeypairs.htm)_ em vez de senha para autenticação. Criamos um par de chaves que consiste em uma _chave privada_ e uma _chave pública_. Como o nome já sugere, a _chave privada_ é sua e não deve ser compartilhada. Já a _chave pública_ é gravada dentro da instância. Esta correlação, entre _chave privada_ e _chave pública_, é que permite uma autenticação com sucesso.

Para criarmos uma _[chave SSH](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/managingkeypairs.htm)_, usaremos o utilitário **[ssh-keygen](https://www.openssh.com/portable.html)** disponível na maioria das distribuições Linux. Caso esteja utilizando um sistema operacional Windows para criar as chaves, você precisará do utilitário _[PuTTYgen](https://www.putty.org/)_. Lembrando que as chaves suportadas para _[imagens de plataforma](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images)_ são: _RSA, DSA, DSS, ECDSA e Ed25519_. Para chaves _RSA, DSS e DSA_, recomenda-se um mínimo de **2048 bits**. Para chaves _ECDSA_, é recomendável no mínimo **256 bits**. Consulte este _[link](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/managingkeypairs.htm#public-key-format)_ para maiores detalhes.

>_**__NOTA:__** Por padrão, o utilitário [PuTTYgen](https://www.putty.org/) salva as chaves em um formato proprietário chamado "PPK (PuTTY Private Key)". Este funciona somente com o conjunto de ferramentas do [PuTTY](https://www.putty.org/), que é incompatível com o formato entendido pelo [OpenSSH](https://www.openssh.com/). Porém, o [PuTTYgen](https://www.putty.org/) também permite salvar as chaves no formato do [OpenSSH](https://www.openssh.com/). Lembre-se de usar a opção apropriada quando for salvar suas chaves._

Para criar uma chave sem _"frase-senha"_, usamos o comando abaixo:

```
darmbrust@hoodwink:~$ ssh-keygen -t rsa -N "" -b 2048 -f wordpress-key
Generating public/private rsa key pair.
Your identification has been saved in wordpress-key
Your public key has been saved in wordpress-key.pub
The key fingerprint is:
SHA256:HALqKyhxjEvT/cFr3sxLhmH2d5e3YFxp1b4v+aUFVCc darmbrust@hoodwink
The key's randomart image is:
+---[RSA 2048]----+
|    .         E o|
|   . .         oo|
|  .   . .     . o|
| +. . .o .   . .o|
|oo+. . *S     .+.|
|o+..  + *   . o.o|
|= .    = + . = =+|
|..    o * . o =o=|
|       . =.   .+o|
+----[SHA256]-----+
```

>_**__NOTA:__** Caso queira especificar uma "frase-senha" e adicionar uma camada extra de segurança, retire os argumentos _-N ""_ do comando acima._

Como resultado, dois arquivos foram criados que correspondem a _chave privada_ e _chave pública_ (extensão .pub):

```
darmbrust@hoodwink:~$ ls -1 wordpress-key*
wordpress-key
wordpress-key.pub
```

Você também pode criar sua _[chave SSH](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/managingkeypairs.htm)_ através da _[Web Console](https://docs.oracle.com/pt-br/iaas/Content/GSG/Tasks/signingin.htm#Signing_In_to_the_Console)_ quando cria uma instância. Porém, como tudo aqui é orientado a código, não entraremos nesses detalhes.

#### __Criando a Instância__

Antes de criarmos a instância, precisamos obter o OCID da subrede que já foi criada. Primeiramente, precisamos do OCID do compartimento que a subrede foi criada:

```
darmbrust@hoodwink:~$ oci iam compartment list --compartment-id-in-subtree true --name "cmp-network" --query "data[].id"
[
  "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq"
]
```

Agora, podemos consultar o nome da subrede pelo OCID do compartimento que acabamos de obter:

```
darmbrust@hoodwink:~$ oci network subnet list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --query "data[?\"display-name\"=='subnprv-app_vcn-prd'].id"
[
  "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaajb4wma763mz6uowun3pfeltobe4fmiegdeyma5ehvnf3kzy3jvxa"
]
```

Lembrando que a instância será criada no compartimento "cmp-app". Precisamos do seu OCID também:

```
darmbrust@hoodwink:~$ oci iam compartment list --compartment-id-in-subtree true --name "cmp-app" --query "data[].id"
[
  "ocid1.compartment.oc1..aaaaaaaamcff6exkhvp4aq3ubxib2wf74v7cx22b3yj56jnfkazoissdzefq"
]
```

Juntando as informações, criaremos a instância com o comando abaixo:

```
darmbrust@hoodwink:~$ oci compute instance launch \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaamcff6exkhvp4aq3ubxib2wf74v7cx22b3yj56jnfkazoissdzefq" \
> --availability-domain "ynrK:SA-SAOPAULO-1-AD-1" \
> --shape "VM.Standard2.2" \
> --subnet-id "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaajb4wma763mz6uowun3pfeltobe4fmiegdeyma5ehvnf3kzy3jvxa" \
> --boot-volume-size-in-gbs 100 \
> --display-name "vm-wordpress_subnprv-app_vcn-prd" \
> --fault-domain "FAULT-DOMAIN-3" \
> --hostname-label "wordpress" \
> --image-id "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaasahnls6nmev22raz7ecw6i64d65fu27pmqjn4pgz7zue56ojj7qq" \
> --ssh-authorized-keys-file ./wordpress-key.pub 
> --wait-for-state "RUNNING"
Action completed. Waiting until the resource has entered state: ('RUNNING',)
{
  "data": {
    "agent-config": {
      "are-all-plugins-disabled": false,
      "is-management-disabled": false,
      "is-monitoring-disabled": false,
      "plugins-config": null
    },
    "availability-config": {
      "is-live-migration-preferred": null,
      "recovery-action": "RESTORE_INSTANCE"
    },
    "availability-domain": "ynrK:SA-SAOPAULO-1-AD-1",
    "capacity-reservation-id": null,
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaamcff6exkhvp4aq3ubxib2wf74v7cx22b3yj56jnfkazoissdzefq",
    "dedicated-vm-host-id": null,
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-07T22:29:56.823Z"
      }
    },
    "display-name": "vm-wordpress_subnprv-app_vcn-prd",
    "extended-metadata": {},
    "fault-domain": "FAULT-DOMAIN-3",
    "freeform-tags": {},
    "id": "ocid1.instance.oc1.sa-saopaulo-1.antxeljr6noke4qcf4yilvaofwpt5aiavnsx7cfev3fhp2bpc3xfcxo5k6zq",
    "image-id": "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaasahnls6nmev22raz7ecw6i64d65fu27pmqjn4pgz7zue56ojj7qq",
    "instance-options": {
      "are-legacy-imds-endpoints-disabled": false
    },
    "ipxe-script": null,
    "launch-mode": "PARAVIRTUALIZED",
    "launch-options": {
      "boot-volume-type": "PARAVIRTUALIZED",
      "firmware": "UEFI_64",
      "is-consistent-volume-naming-enabled": true,
      "is-pv-encryption-in-transit-enabled": false,
      "network-type": "PARAVIRTUALIZED",
      "remote-data-volume-type": "PARAVIRTUALIZED"
    },
    "lifecycle-state": "RUNNING",
    "metadata": {
      "ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWUt3EgmmEZtWLOuAvwO/DEpddReosK4rmD1IU6Qm41fIq9lQ/qxm5yP9tSb8XzaJCDKzSxB2byOIqQ5vy21L8cQ59SLnU6uMql4Tf0qfdcM4mX3ZbAjDBu8+OTaJkGRIXnGjg1FdUi+eFO/Bg/X7qYMsIEpINpmhBBm3xIIYk89+Or7KqcWSnHIAHg701cLQBDVx5/biSGjoAjnHGESyg+CBlk1EaXc9IhXPGhtN1ErI+D+g7GGCz12+JHVoBPsn2+qTOgX1eiSr0B5eVtVNBOThrbC1BrtkucYtUUsOOO2jh5t4FdwixLdt+vWcSEaqOoFwD6fPJFBu4TN6E2lqt darmbrust@hoodwink\n"
    },
    "platform-config": null,
    "preemptible-instance-config": null,
    "region": "sa-saopaulo-1",
    "shape": "VM.Standard2.2",
    "shape-config": {
      "baseline-ocpu-utilization": null,
      "gpu-description": null,
      "gpus": 0,
      "local-disk-description": null,
      "local-disks": 0,
      "local-disks-total-size-in-gbs": null,
      "max-vnic-attachments": 2,
      "memory-in-gbs": 30.0,
      "networking-bandwidth-in-gbps": 2.0,
      "ocpus": 2.0,
      "processor-description": "2.0 GHz Intel\u00ae Xeon\u00ae Platinum 8167M (Skylake)"
    },
    "source-details": {
      "boot-volume-size-in-gbs": null,
      "image-id": "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaasahnls6nmev22raz7ecw6i64d65fu27pmqjn4pgz7zue56ojj7qq",
      "kms-key-id": null,
      "source-type": "image"
    },
    "system-tags": {},
    "time-created": "2021-09-07T22:29:57.227000+00:00",
    "time-maintenance-reboot-due": null
  },
  "etag": "148d71576982ca3bcb4a2e8e5486974f57d89ed69e7d22ca8242d52c9710c7d0"
}
```

Destaco alguns parâmetros que foram informados para customizar a criação da intância, e que não são obrigatórios. 

A começar pelo parâmetro _"--boot-volume-size-in-gbs"_ que foi usado para especificar um tamanho de **100 GB** para o _[boot volume](https://docs.oracle.com/pt-br/iaas/Content/Block/Concepts/bootvolumes.htm)_, diferente do padrão para sistema operacional Linux que é **50 GB**. 

O próximo parâmetro foi _"--fault-domain"_ no qual eu forcei a criação da instância no _"FAULT-DOMAIN-3"_. Se você não especificar um _"Fault Domain"_, o OCI irá escolher um para você de forma automática. As vezes, especificar este parâmetro, permite que se faça uma distribuição melhor e mais precisa das instâncias entre _"Fault Domains"_ diferentes, evitando o _"[ponto único de falha](https://pt.wikipedia.org/wiki/Ponto_%C3%BAnico_de_falha)"_.

Por último, o parâmetro _"--ssh-authorized-keys-file"_ que especifica o caminho das _chaves SSH públicas_. As _chaves públicas_, existentes no arquivo _"wordpress-key.pub"_, são adicionadas ao arquivo _/home/opc/.ssh/authorized_keys_ da instância no momento da sua criação. Isto irá permitir a autenticação por _[chave SSH](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/managingkeypairs.htm)_, já dito anteriormente.

Instâncias criadas com o uso de imagens _[Oracle Linux](https://www.oracle.com/linux/)_ e _[CentOS](https://pt.wikipedia.org/wiki/CentOS)_, são criadas com o usuário **_opc_**. O usuário **_opc_** tem privilégios ilimitados através de _[sudo](https://pt.wikipedia.org/wiki/Sudo)_. Lembrando que o login através do usuário **_root_** é desabilitado por padrão.

### __Conclusão__

Aqui concluímos este capítulo que apresenta o básico sobre computação no OCI.