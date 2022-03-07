
# Modelo de Machine Learning para prever pobreza
# Script para extracao de dados da PNAD continua
# Extrai variaveis selecionadas e salva em um arquivo .csv

rm(list = ls())
options(scipen = 999)
setwd("C:/Users/vitor/Documents/poverty_classification/paper_2022")


##################### Carregando os pacotes ################################
library(PNADcIBGE)
library(tidyverse)
library(mosaic)

######### Selecionar vari?veis e fazer download dos dados

variaveis <- c("Ano", "Trimestre", "UF", "Capital", 
               "RM_RIDE", "UPA", "V1008", "V1014", 
               "V1022", "V1023", "V1030", "V1032",
               "V2001", "V2005", "V2007", "V2009",
               "V2010", "VD2003", "VD4019", "VD4048",
               "VD5007", "VD5008", "V5004A", 
               "V5004A2", "V5005A", "V5005A2", 
               "V5006A", "V5006A2", "V5007A", 
               "V5007A2", "V5008A", "S01001", 
               "S01002", "S01003", "S01004", 
               "S01005", "S01006", "S01007", "S01010",
               "S01011A", "S01011C", "S01012A", 
               "S01017", "S01018", "S01019",
               "S01021", "S01022", "S01023",
               "S01024", "S01025", "S01028", "S01029",
               "S010311", "S010312", "VD2003", "VD2004", "VD2002",
               "VD3004", "VD3005", "VD3006", "VD4001", "VD4002", "VD4003",
               "VD4004A", "VD4005", "VD4008", "VD4009",
               "VD4010", "VD4011", "VD4012", "VD4013",
               "VD4014", "VD4015", "VD4016", "VD4017",
               "VD4018", "VD4019", "VD4020", "VD4022",
               "VD4030", "VD4031", "VD4035", "VD4036", "VD4037",
               "VD4046", "VD4047", "VD4048", "VD4052",
               "VD5001", "VD5002", "VD5003", "VD5004",
               "VD5005", "VD5006", "VD5007", "VD5008",
               "VD5009", "VD5010", "VD5011")

pnadc19 = get_pnadc(year = 2019,
                    interview = 1,
                    vars = variaveis,
                    design = FALSE,
                    labels = FALSE,
                    deflator = TRUE,
                    defyear = 2019)


# Salvar dados em RDS
saveRDS(pnadc19,"pnadc19")


#############################################
#############################################
# pnadc19 <- readRDS("pnadc19")

class(pnadc19)
glimpse(pnadc19)

##########################
# Montar base apenas com variáveis selecionadas para o Ceará
pov19 <- pnadc19 %>% 
    select('UF', 'UPA', 'V1008', 'V1014', 'V2005', 'VD2002', 'V2009',
           'V2007', 'V2010', 'VD4001', 'VD4002', 'V5004A', 'V1022', 
           'S01007', 'S01010', 'S01011A', 'VD4048', 'VD4019', 
           'CO2e', 'CO2', 'S01001', 'S01007', 'S01012A', 'V1022', 
           'S01002', 'S01017', 'VD3004', 'S01003', 'S01004',
           'S01005', 'S01007', 'S01010', 'S01017', 'S01021', 'S01023', 
           'S01024', 'S01025', 'S01028', 'S01029', 'S010311', 'S010312')

# Exclui base anterior
rm(pnadc19)

# Primeira analise dos dados
colSums(is.na(pov19))

##########################
# pre processamento
######################

# Criar variaveis individuais
pov19 <- pov19 %>% 
    mutate(
        regiao = factor(ifelse(substr(UPA, start=1, stop=1)=="1","Norte",
                               ifelse(substr(UPA, start=1, stop=1)=="2","Nordeste",
                                      ifelse(substr(UPA, start=1, stop=1)=="3","Sudeste",
                                             ifelse(substr(UPA, start=1, stop=1)=="4","Sul",
                                                    ifelse(substr(UPA, start=1, stop=1)=="5","Centro-Oeste",NA))))),
                        levels = c("Norte","Nordeste","Sudeste","Sul","Centro-Oeste")),
        
        hh_id = as.numeric(paste(UPA,V1008,V1014, sep = "")),
        membro = ifelse (VD2002 < 15, 1, 0),
        chefe = ifelse (VD2002== "01", 1, 0),
        conjuge = ifelse (VD2002== "02", 1, 0),
        idade = V2009,
        crianca = ifelse (V2009 <=14, 1, 0),
        adulto = ifelse (V2009 >= 14, 1, 0),
        genero = factor(case_when(V2007==1 ~ "homem",
                                  V2007==2 ~ "mulher")),
        raca = factor(case_when(V2010==1 | V2010==3 ~ "branco",
                                V2010==2 | V2010==4 | V2010==5 ~ "preto ou pardo")),
        ocupado = factor(case_when(VD4002==1 ~ "ocupado",
                                   VD4002==2 ~ "desocupado")),
        econ_ativo = factor(case_when(VD4001==1 ~ "econ.ativo",
                                         VD4001==2 ~ "econ.inativo")),
        atividade = factor(case_when(VD4001==1 & VD4002==1 ~ "ativo ocupado",
                                        VD4001==1 & VD4002==2 ~ "ativo desocupado",
                                        VD4001==2 ~ "inativo")),
        aposentadoria = factor(ifelse (V5004A==1 & !is.na(V5004A), "sim", "nao")),
        escolaridade = factor(case_when(VD3004==1 ~ "sem instrucao",
                                           VD3004==2 ~ "fundam incompleto",
                                           VD3004==3 ~ "fundam completo",
                                           VD3004==4 ~ "medio incompleto",
                                           VD3004==5 ~ "medio completo",
                                           VD3004==6 ~ "superior incompleto",
                                           VD3004==7 ~ "superior completo")),
         area = factor(case_when(V1022==1 ~ "urbano",
                                   V1022==2 ~ "rural")),
           
         ### Contruir vari?veis de renda
         VD4048 = ifelse (is.na (VD4048), 0, VD4048),
         VD4019 = ifelse (is.na (VD4019), 0, VD4019),
         other_def = VD4048 * CO2e,
         labor_def = VD4019 * CO2,
         renda = other_def + labor_def )

# Criar variaveis agregadas por domicilio
pov19ce <- pov19ce %>% group_by(hh_id) %>% 
    mutate(n_moradores = sum(membro),
           n_criancas = sum(crianca),
           n_adultos = sum(adulto),
           parceiro = sum(conjuge),
           # Construir vari?vel de renda domiciliar total e rdpc
           renda_dom = ifelse(membro==1, sum(renda), NA),
           rdpc=renda_dom/n_moradores )

pov19ce <- pov19ce %>% mutate(
    # Criar variaveis de caracteristicas dos domicilios
    casal = factor(case_when(parceiro==1 ~ "casado",
                             parceiro==0 ~ "solteiro")),
    dom_tipo = factor(case_when(S01001==1 ~ "casa",
                                S01001==2 ~ "apartamento",
                                S01001==3 ~ "outros")),
    agua_fonte = factor(case_when(S01007==1 ~ "rede geral",
                                  S01007==2 ~ "poco profundo",
                                  S01007==3 ~ "poco raso",
                                  S01007==4 ~ "fonte",
                                  S01007==5 ~ "agua chuva armaz",
                                  S01007==6 ~ "outra")),
    agua_rede = factor(ifelse(S01007==1, "sim", "nao")),
    agua_canalizada = factor(ifelse(S01010==1, "sim", "nao")),
    agua_adeq = factor(ifelse((S01007==1 | S01007==2) & S01010==1, "adequada", "inadequada")),
    esgoto_ad = factor(case_when(S01012A==1 & V1022==1 ~ "adequado",
                                 S01012A==2 & V1022==1 ~ "adequado",
                                 S01012A>=3 & V1022==1 ~ "inadequado",
                                 S01012A<=3 & V1022==2 ~ "adequado",
                                 S01012A>=4 & V1022==2 ~ "inadequado")),
    banheiro = factor(ifelse(S01011A>=1, "sim", "nao")),
    paredes = factor(case_when(S01002==1 | S01002==2 | S01002==4 ~ "adequada",
                               S01002==3 | S01002>=5 ~ "inadequada")),
    casa_tipo = factor(case_when(S01017==1 ~ "proprio pago",
                                 S01017==2 ~ "proprio nao pago",
                                 S01017==3 ~ "alugado",
                                 S01017%in% 4:6 ~ "cedido",
                                 S01017==7 ~ "outro")),
    cobertura_tipo = S01003,
    piso_tipo = S01004,
    n_comodos = S01005,
    densidade = n_moradores/ n_comodos,
    casa_propria = factor(ifelse(S01017==1 | S01017==2, "sim", "nao")),
    fone_pc = S01021/n_adultos,
    geladeira = factor(ifelse(S01023==1, "sim", "nao")),
    maquina_lavar = factor(ifelse(S01024==1, "sim", "nao")),
    tv = factor(ifelse(S01025%in%1:3, "sim", "nao")),
    computador = factor(ifelse(S01028==1, "sim", "nao")),
    internet = factor(ifelse(S01029==1, "sim", "nao")),
    carro = factor(ifelse(S010311==1, "sim", "nao")),
    moto = factor(ifelse(S010312==1, "sim", "nao")))


# Criar variaveis de pobreza
## Linhas de pobreza do Banco Mundial (bm) 1/2 sm.
lepbm <- 151  # US$ 1,90/dia ~ R$151/m?s
lpbm <- 436   # US$ 5,5/dia ~ R$436/m?s 

pov19 <- pov19ce %>% 
    mutate(pobre = factor(ifelse (rdpc< lpbm & !is.na(rdpc), "pobre", "nao pobre")),
           pobre_ex = factor(ifelse (rdpc< lepbm & !is.na(rdpc), "pobre ex", "nao pobre ex")))

######################################################

pov <- pov19 %>% filter(chefe==1) %>% 
    select(UF, regiao, hh_id, pobre, pobre_ex, area, labor_def, other_def, rdpc,
           n_moradores, n_criancas, n_adultos, casal, 
           idade, genero, raca, escolaridade, atividade, aposentadoria,
           dom_tipo, agua_adeq, esgoto_ad, banheiro, paredes, casa_tipo, 
           densidade, fone_pc, geladeira, maquina_lavar, tv, computador,
           internet, carro, moto)

# Salvar
#saveRDS(povce, file="pov19ce")

write.csv(pov,'pov19.csv')

######################################################
