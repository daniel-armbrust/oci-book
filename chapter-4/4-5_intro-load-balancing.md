# Capítulo 4: Primeira aplicação no OCI

## 4.5 - Introdução ao Serviço de Load Balancer

### __Introdução__

_Load Balancer_, _Balanceador de Carga_ ou _LBaaS_ são alguns nomes que identificam o _[Serviço de Load Balancing](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_ disponível no _[OCI](https://www.oracle.com/cloud/)_. 

Sua principal função é realizar a distribuição do tráfego de um ponto de entrada, para vários servidores existentes em sua _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_. Além de distribuir a _"carga de trabalho"_ entre duas ou mais intâncias de computação, temos uma melhor utilização dos recursos, possibilidade de escalonamento e alta disponibilidade.
 
Uma das formas de empregar a _["alta disponibilidade"](https://en.wikipedia.org/wiki/High_availability)_ através do _[Serviço de Load Balancing](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_, se dá pela configuração de políticas de _"Health Check"_, que basicamente realiza testes de forma contínua a nível de rede com o intuíto de confirmar a disponibilidade _(vivo ou morto)_ dos recursos que estão _"atrás"_ do _[Load Balancer](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_.
