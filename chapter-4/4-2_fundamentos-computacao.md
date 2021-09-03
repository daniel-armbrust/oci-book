# Capítulo 4: Primeira aplicação no OCI

## 4.2 - Fundamentos do Serviço de Computação

### __Visão Geral__

O _[Serviço de Computação](https://docs.oracle.com/pt-br/iaas/Content/Compute/Concepts/computeoverview.htm)_ permite criar e gerenciar hosts de computação, conhecidos como **instâncias**. Uma instância de computação deve obrigatóriamente ser criada e residir em um _"[Dominio de Disponibilidade (Availability Domains ou AD)](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm#top)"_, e pode ser uma **_Máquina Virtual (VM ou Virtual Machine)_** ou uma **_Máquina Física (BM ou Bare Metal)_**. 

Uma instância _Bare Metal (BM)_ concede a você, acesso a um servidor físico e dedicado, de altíssimo desempenho e sem um _[hipervisor](https://pt.wikipedia.org/wiki/Hipervisor)_. Neste modelo, além de não ser preciso compartilhar a máquina física, você tem acessos e controles exclusivos sobre a CPU, memória e placa de rede (NIC) da máquina. É como se fosse um hardware em execução no seu próprio data center.

Já uma _Máquina Virtual (VM)_ é executada através de técnicas de virtualização, que possibilita diferentes máquinas coexistirem, de forma isoladas, sobre um hardware físico (um computador maior).

![alt_text](./images/ch4_4-2_bm-vs-vm.jpg  "Bare Metal vs. Virtual Machine")