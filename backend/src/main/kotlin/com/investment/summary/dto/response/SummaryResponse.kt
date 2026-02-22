package com.investment.summary.dto.response

import com.investment.summary.domain.entity.Category
import com.investment.summary.domain.entity.InvestmentSummary
import com.investment.summary.domain.entity.MarketSentiment
import java.time.LocalDate
import java.time.LocalDateTime

data class SummaryResponse(
    val id: Long,
    val category: String,
    val categoryDisplayName: String,
    val summaryDate: LocalDate,
    val title: String,
    val content: String,
    val sourceUrl: String?,
    val marketSentiment: String,
    val marketSentimentDisplayName: String,
    val createdAt: LocalDateTime
)

fun InvestmentSummary.toResponse() = SummaryResponse(
    id = id,
    category = category.name,
    categoryDisplayName = category.displayName,
    summaryDate = summaryDate,
    title = title,
    content = content,
    sourceUrl = sourceUrl,
    marketSentiment = marketSentiment.name,
    marketSentimentDisplayName = marketSentiment.displayName,
    createdAt = createdAt
)
