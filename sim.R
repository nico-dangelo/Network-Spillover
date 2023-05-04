library(igraph)
sim <-
  function(N = 20,
           phiv = 0.1,
           PrEP1 = 0.1,
           PrEP2 = 0.2,
           p1 = 0.2,
           p2 = 0.1,
           plots = F,
           model = c("ER", "BA", "WS"),
           eprob = 3/N,
           pow = 1,
           nb = 5,
           rprob = 0.05) {
    #parameter check
    model <- match.arg(model, several.ok = FALSE)
    #store arguments
    args <- c(N, phiv, PrEP1, PrEP2, p1, p2, model, eprob, pow, nb, rprob)
    names(args) <-
      c("N",
        "phiv",
        "PrEP1",
        "PrEP2",
        "p1",
        "p2",
        "model",
        "eprob",
        "pow",
        "nb",
        "rprob")
    #control scenario graph, PrEP1% assignment prob
    g <-
      if (model == "ER") {
        sample_gnp(N, eprob)
      } else if (model == "BA") {
        sample_pa(N, power = pow, directed = FALSE)
      } else if (model == "WS") {
        sample_smallworld(
          dim = 1,
          size = N,
          nei = nb,
          p = rprob
        )
      }
    l_hiv_g <- round((gorder(g) * phiv), 0)
    l_PrEP1_g <- round(((gorder(g) - l_hiv_g) * PrEP1), 0)
    l_sus_g <- round((gorder(g) - (l_hiv_g + l_PrEP1_g)), 0)
    vertex_attr(g) <-
      list(color = c(
        rep("red", l_hiv_g),
        rep("blue", l_PrEP1_g),
        rep("black", l_sus_g)
      ))
    if (plots) {
      coords = layout_nicely(g)
      plot(
        g,
        vertex.size = 10,
        vertex.label.cex = 1,
        vertex.label.dist = 2,
        main = "Control",
        layout = coords
      )
    }
    inf_contact_g <-
      setdiff(unlist(adjacent_vertices(g, v = V(g)[color == "red"])), V(g)[color ==
                                                                             "red"])
    #compute P(HIV|PrEP)
    treat_g <- V(g)[V(g)$color == "blue"]
    treat_inf_contact_g <-
      V(g)[inf_contact_g][which(V(g)[inf_contact_g]$color == "blue")]
    g <-
      set_vertex_attr(g,
                      name = "color",
                      index = inf_contact_g,
                      value = "orange")
    g <-
      set_vertex_attr(g,
                      name = "color",
                      index = treat_inf_contact_g,
                      value = "purple")
    if (plots) {
      plot(
        g,
        vertex.size = 10,
        vertex.label.cex = 1,
        vertex.label.dist = 2,
        main = "Control",
        layout = coords
      )
    }
    hiv_given_prep_g <-
      ifelse(length(treat_g) != 0, (length(treat_inf_contact_g) * p2) / length(treat_g), 0)
    #Compute P(HIV|-PrEP)
    no_treat_g <- V(g)[V(g)$color %in% c("black", "orange")]
    no_treat_inf_contact_g <- V(g)[V(g)$color == "orange"]
    hiv_given_no_prep_g <-
      ifelse(length(no_treat_g) != 0, (length(no_treat_inf_contact_g) * p1) /
               length(no_treat_g), 0)
    #Randomly assign PrEP2% overall (shuffle attributes)
    l_hiv_h <- round((gorder(g) * phiv), 0)
    l_PrEP2_h <- round(((gorder(g) - l_hiv_h) * PrEP2), 0)
    l_sus_h <- round((gorder(g) - (l_hiv_h + l_PrEP2_h)), 0)
    h <-
      set_vertex_attr(g, "color", value = c(rep("red", l_hiv_h), sample(c(
        rep("blue", l_PrEP2_h), rep("black", l_sus_h)
      ))))
    if (plots) {
      plot(
        h,
        vertex.size = 10,
        vertex.label.cex = 1,
        vertex.label.dist = 2,
        main = "Random overall",
        layout = coords
      )
    }
    inf_contact_h <-
      setdiff(unlist(adjacent_vertices(h, v = V(h)[color == "red"])), V(h)[color ==
                                                                             "red"])
    #Compute P(HIV|PrEP)
    treat_h <- V(h)[V(h)$color == "blue"]
    treat_inf_contact_h <-
      V(h)[inf_contact_h][which(V(h)[inf_contact_h]$color == "blue")]
    h <-
      set_vertex_attr(h,
                      name = "color",
                      index = inf_contact_h,
                      value = "orange")
    h <-
      set_vertex_attr(h,
                      name = "color",
                      index = treat_inf_contact_h,
                      value = "purple")
    if (plots) {
      plot(
        h,
        vertex.size = 10,
        vertex.label.cex = 1,
        vertex.label.dist = 2,
        main = "Random overall",
        layout = coords
      )
    }
    hiv_given_prep_h <-
      ifelse(length(treat_h) != 0, (length(treat_inf_contact_h) * p2) / length(treat_h), 0)
    #Compute P(HIV|-PrEP)
    no_treat_h <- V(h)[V(h)$color %in% c("black", "orange")]
    no_treat_inf_contact_h <- V(h)[V(h)$color == "orange"]
    hiv_given_no_prep_h <-
      ifelse(length(no_treat_h) != 0, (length(no_treat_inf_contact_h) * p1) /
               length(no_treat_h), 0)
    #duplicate network structure, additional PrEP2-PrEP1% treated
    l_hiv_j <- round((gorder(g) * phiv), 0)
    l_PrEP2_j <- round(((gorder(g) - l_hiv_j) * PrEP2), 0)
    l_sus_j <- round((gorder(g) - (l_hiv_j + l_PrEP2_j)), 0)
    j <-
      set_vertex_attr(g, "color", value = c(
        rep("red", l_hiv_j),
        rep("blue", l_PrEP2_j),
        rep("black", l_sus_j)
      ))
    if (plots) {
      plot(
        j,
        vertex.size = 10,
        vertex.label.cex = 1,
        vertex.label.dist = 2,
        main = "Random additional",
        layout = coords
      )
    }
    inf_contact_j <-
      setdiff(unlist(adjacent_vertices(j, v = V(j)[color == "red"])), V(j)[color ==
                                                                             "red"])
    #compute (HIV|PrEP)
    treat_j <- V(j)[V(j)$color == "blue"]
    treat_inf_contact_j <-
      V(j)[inf_contact_j][which(V(j)[inf_contact_j]$color == "blue")]
    j <-
      set_vertex_attr(j,
                      name = "color",
                      index = inf_contact_j,
                      value = "orange")
    j <-
      set_vertex_attr(j,
                      name = "color",
                      index = treat_inf_contact_j,
                      value = "purple")
    if (plots) {
      plot(
        j,
        vertex.size = 10,
        vertex.label.cex = 1,
        vertex.label.dist = 2,
        main = "Random additional",
        layout = coords
      )
    }
    hiv_given_prep_j <-
      ifelse(length(treat_j) != 0, (length(treat_inf_contact_j) * p2) / length(treat_j), 0)
    #Compute P(HIV|-PrEP)
    no_treat_j <- V(j)[V(j)$color %in% c("black", "orange")]
    no_treat_inf_contact_j <- V(j)[V(j)$color == "orange"]
    hiv_given_no_prep_j <-
      ifelse(length(no_treat_j) != 0, (length(no_treat_inf_contact_j) * p1) /
               length(no_treat_j), 0)
    # Regenerated graph
    k <-
      if (model == "ER") {
        sample_gnp(N, eprob)
      } else if (model == "BA") {
        sample_pa(N, power = pow, directed = FALSE)
      } else if (model == "WS") {
        sample_smallworld(
          dim = 1,
          size = N,
          nei = nb,
          p = rprob
        )
      }
    l_hiv_k <- round((gorder(k) * phiv), 0)
    l_PrEP2_k <- round(((gorder(k) - l_hiv_k) * PrEP2), 0)
    l_sus_k <- round((gorder(k) - (l_hiv_k + l_PrEP2_k)), 0)
    vertex_attr(k) <-
      list(color = c(
        rep("red", l_hiv_k),
        rep("blue", l_PrEP2_k),
        rep("black", l_sus_k)
      ))
    if (plots) {
      plot(
        k,
        vertex.size = 10,
        vertex.label.cex = 1,
        vertex.label.dist = 2,
        main = "Regenerated",
        layout = coords
      )
    }
    inf_contact_k <-
      setdiff(unlist(adjacent_vertices(k, v = V(k)[color == "red"])), V(k)[color ==
                                                                             "red"])
    #Compute P(HIV|PrEP)
    treat_k <- V(k)[V(k)$color == "blue"]
    treat_inf_contact_k <-
      V(k)[inf_contact_k][which(V(k)[inf_contact_k]$color == "blue")]
    k <-
      set_vertex_attr(k,
                      name = "color",
                      index = inf_contact_k,
                      value = "orange")
    k <-
      set_vertex_attr(k,
                      name = "color",
                      index = treat_inf_contact_k,
                      value = "purple")
    if (plots) {
      plot(
        k,
        vertex.size = 10,
        vertex.label.cex = 1,
        vertex.label.dist = 2,
        main = "Regenerated",
        layout = coords
      )
    }
    hiv_given_prep_k <-
      ifelse(length(treat_k) != 0, (length(treat_inf_contact_k) * p2) / length(treat_k), 0)
    #Compute P(HIV|-PrEP)
    no_treat_k <- V(k)[V(k)$color %in% c("black", "orange")]
    no_treat_inf_contact_k <- V(k)[V(k)$color == "orange"]
    hiv_given_no_prep_k <-
      ifelse(length(no_treat_k) != 0, (length(no_treat_inf_contact_k) * p1) /
               length(no_treat_k), 0)
    #Network Summary Statistics
    stats_g <- c(
      Co_g <- count_components(g),
      #Number of Components
      Cs_g <- max(components(g)$csize),
      #Largest Component Size
      B_g <- mean(betweenness(g)),
      # Average Betweenness Centrality
      De_g <- edge_density(g),
      #Density
      Ce_g <- centr_degree(g)$centralization,
      #Degree Centralization
      G_g <- mean_distance(g),
      #Average geodesic distance
      Di_g <- diameter(g),
      #Network Diameter
      T_g <- transitivity(g),
      #Transitivity/Clustering
      K_g <-
        sum(coreness(g) == 2) / length(coreness(g)),
      #Proportion of nodes in 2-cores
      As_g <- assortativity_degree(g, directed = F) #Degree Assortativity
    )
    names(stats_g) <-
      c(
        "Number of Components g",
        "Largest Component Size g",
        "Avg. Betweenness g",
        "Density g",
        "Degree Centralization g",
        "Avg. Geodesic Distance g",
        "Diameter g",
        "Transitivity g",
        "Proportion of nodes in 2-cores g",
        "Degree Assortativity g"
      )
    stats_k <- c(
      Co_k <- count_components(k),
      #Number of Components
      Cs_k <- max(components(k)$csize),
      #Largest Component Size
      B_k <- mean(betweenness(k)),
      # Average Betweenness Centrality
      De_k <- edge_density(k),
      #Density
      Ce_k <- centr_degree(k)$centralization,
      #Degree Centralization
      G_k <- mean_distance(k),
      #Average geodesic distance
      Di_k <- diameter(k),
      #Network Diameter
      T_k <- transitivity(k),
      #Transitivity/Clustering
      K_k <-
        sum(coreness(k) == 2) / length(coreness(k)),
      #Proportion of nodes in 2-cores,
      As_k <- assortativity_degree(k, directed = F) #Degree Assortativity
    )
    names(stats_k) <-
      c(
        "Number of Components k",
        "Largest Component Size k",
        "Avg. Betweenness k",
        "Density k",
        "Degree Centralization k",
        "Avg. Geodesic Distance k",
        "Diameter k",
        "Transitivity k",
        "Proportion of nodes in 2-cores k",
        "Degree Assortativity k"
      )
    # Combine effect estimates
    prep <-
      c(hiv_given_prep_g,
        hiv_given_prep_h,
        hiv_given_prep_j,
        hiv_given_prep_k)
    names(prep) <-
      c("hiv_given_prep_g",
        "hiv_given_prep_h",
        "hiv_given_prep_j",
        "hiv_given_prep_k")
    no_prep <-
      c(
        hiv_given_no_prep_g,
        hiv_given_no_prep_h,
        hiv_given_no_prep_j,
        hiv_given_no_prep_k
      )
    names(no_prep) <-
      c(
        "hiv_given_no_prep_g",
        "hiv_given_no_prep_h",
        "hiv_given_no_prep_j",
        "hiv_given_no_prep_k"
      )
    ef <- prep + no_prep
    names(ef) <- c("control,", "random", "additive", "regenerated")
    #compute causal contrasts
    cc <- as.data.frame(t(ef[-1] - ef[1]))
    names(cc) <- c("random", "additive", "regenerated")
    res <-
      cbind(
        as.data.frame(t(args)),
        as.data.frame(t(prep)),
        as.data.frame(t(no_prep)),
        cc,
        as.data.frame(t(stats_g)),
        as.data.frame(t(stats_k))
      )
    names(res) <-
      c(
        names(args),
        names(prep),
        names(no_prep),
        names(cc),
        names(stats_g),
        names(stats_k)
      )
    return(res)
  }