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

### __Instância do Wordpress__

Já estudamos o básico sobre shape e imagem. Agora é hora de criarmos nossa primeira instância para hospedar o _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_. Antes de mais nada, precisamos de algumas informações em mãos, para preencher alguns parâmetros obrigatórios do comando que irá criar a instância.

#### __Compartimento__

#### __Dominio de Disponibilidade (Availability Domains ou AD)__

#### __Shape e Imagem__

#### __Chave SSH__

#### __Criando a Instância__