#install.packages("rJava")
#library(rJava)
#This step will be repeated multiple times, using the same command, only
#changing the name of the output file. Here we have generated 5 runs, prefixed
#cluster1, 2, 3, 4, 5. We can obtain five cluster files.
#data_file is expression data
#Each line of the cluster1(2,3,4,5)file must be according to the following format:
#geneSymbol moduleId
# -data_file expression data 
command <- paste0("java -jar ganesh.jar -task ganesh -data_file data\\expr_matrix.txt -output_file cluster1")
system(command, intern=TRUE)


#Construct matrix C(k), C(k) is an N*Sk matrix where N is the number of genes and Sk is the number of clusters in the kth run ganesh
system("javac ConstructC.java")
system("java ConstructC")

#N * N co-clustering matrix O(k) = C(k)*C(k)T
#cluster1.output.txt is the result of 'ConstructC.java'
cluster1 = read.table("cluster1.output.txt")
t_cluster1 = t(cluster1)
o1 = cluster1 %*% t_cluster1
cluster1=as.matrix(cluster1[1:nrow(cluster1),1:ncol(cluster1)])
#write.csv(o1,file = "o1.csv")

cluster2 = read.table("cluster2.output.txt")
t_cluster2 = t(cluster2)
o2 = cluster2 %*% t_cluster2
cluster2=as.matrix(cluster2[1:nrow(cluster2),1:ncol(cluster2)])
#write.csv(o1,file = "o2.csv")

cluster3 = read.table("cluster3.output.txt")
t_cluster3 = t(cluster3)
o3 = cluster3 %*% t_cluster3
cluster3=as.matrix(cluster3[1:nrow(cluster3),1:ncol(cluster3)])
#write.csv(o1,file = "o3.csv")

cluster4 = read.table("cluster4.output.txt")
t_cluster4 = t(cluster4)
o4 = cluster4 %*% t_cluster4
cluster4=as.matrix(cluster4[1:nrow(cluster4),1:ncol(cluster4)])
#write.csv(o4,file = "o4.csv")

cluster5 = read.table("cluster5.output.txt")
t_cluster5 = t(cluster5)
o5 = cluster5 %*% t_cluster5
cluster5=as.matrix(cluster5[1:nrow(cluster5),1:ncol(cluster5)])
#write.csv(o5,file = "o5.csv")

#contruct matrix O
match1 = match(rownames(o1),rownames(o2))
match2 = as.matrix(match(colnames(o1),colnames(o2)))
o1[1:nrow(o1),1:nrow(o1)] =o1[1:nrow(o1),1:nrow(o1)] + o2[match1,match2]

match3_1 = match(rownames(o1),rownames(o3))
match3_2 = match(colnames(o1),colnames(o3))
o1[1:nrow(o1),1:nrow(o1)] =o1[1:nrow(o1),1:nrow(o1)] + o3[match3_1,match3_2]

match4_1 = match(rownames(o1),rownames(o4))
match4_2 = match(colnames(o1),colnames(o4))
o1[1:nrow(o1),1:nrow(o1)] =o1[1:nrow(o1),1:nrow(o1)] + o4[match4_1,match4_2]

match5_1 = match(rownames(o1),rownames(o5))
match5_2 = match(colnames(o1),colnames(o5))
o1[1:nrow(o1),1:nrow(o1)] =o1[1:nrow(o1),1:nrow(o1)] + o5[match5_1,match5_2]

#G=1/k(sum(o1+o2+o3+o4+o5))
G=o1/5
#write.csv(G,file = "A:\\mai\\lemontree_v3.0.4\\data\\add_cnv_to_gene_expr_lemon_tree\\cluster\\G.csv")

#G->interaction matrix
system("javac GtoInteraction.java")
system("java GtoInteraction")

#read the gene interaction table
gene_association1=read.table("G1.txt")
   
#add ppi_interaction
ppi_interaction = read.table("ppi_interaction.txt")
match1 = match(paste(gene_association1$V1,gene_association1$V2),paste(ppi_interaction$V1,ppi_interaction$V2))
#sum(is.na(match1))
num1 = 1:nrow(gene_association1)
match1 = as.matrix(match1)
num1 = as.matrix(num1)
num1 = num1[-which(is.na(match1)),]
match1 = match1[-which(is.na(match1)),]
gene_association1[num1,3] = gene_association1[match1,3]


match2 = match(paste(gene_association1$V1,gene_association1$V2),paste(ppi_interaction$V2,ppi_interaction$V1))
sum(is.na(match2))
num2 = 1:nrow(gene_association1)
match2 = as.matrix(match2)
num2 = as.matrix(num2)
num2 = num2[-which(is.na(match2)),]
match2 = match2[-which(is.na(match2)),]
gene_association1[num2,3] = gene_association1[match2,3]



gene_association1 = gene_association1[order(gene_association1[,3],decreasing=T),]
gene_inter_0.4 = gene_association1[which((gene_association1[,3]>=0.4)),]
write.table(gene_inter_0.4,file = "gene_0.4_inter.txt",sep="\t",quote=F,row.names=FALSE,col.names = FALSE)

#final cluster
#-s sets the minimum size of the predicted complexes
#-d sets the minimum density of predicted complexes.
#-F specifies the format of the output file
#--seed-method specifies the seed generation method to use. 
command <- paste0("java -jar final_clustering.jar gene_inter_0.4.txt -s 10 -d 0.5 -F plain --seed-method unused_nodes")
xx=system(command, intern=TRUE)
#obtain the community genes
write.table(xx,file = "community.txt")


