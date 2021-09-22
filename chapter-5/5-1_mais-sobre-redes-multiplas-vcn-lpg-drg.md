# Capítulo 5: Mais sobre Redes no OCI

## 5.1 - Conectando múltiplas VCNs na mesma região

### __Local Peering Gateway (LGP)__

_[Local Peering Gateway (LPG)](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ é um recurso que permite conectar duas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ na mesma região possiblitando comunicação via endereços IP privados e sem rotear o tráfego pela internet. As _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ podem estar no mesmo _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_ ou em _[tenancies](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_ distintos. 

Lembrando que se não houver pareamento via _[LGP](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ entre duas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_, é necessário a utilização de um _[Internet Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingIGs.htm#Internet_Gateway)_ e endereços IP públicos. Porém, isto acaba expondo a comunicação dos seus recursos de forma indevia pela internet.

Demonstraremos a criação do _[Local Peering Gateway (LPG)](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ conforme o desenho abaixo:

![alt_text](./images/ch5-1_lpg-1.jpg "Local Peering Gateway (LGP)")

Lembre-se que as duas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ que se conectam via _[LPG](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_, necessitam ter blocos _[CIDRs](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)_ diferentes (sem sobreposição) e estar na mesma região.
