package com.investment.summary.dto.request

import jakarta.validation.constraints.NotBlank
import java.time.LocalDate

data class SummaryRequest(
    val date: LocalDate = LocalDate.now(),

    @field:NotBlank(message = "시장 데이터는 필수입니다.")
    val marketData: String
)
