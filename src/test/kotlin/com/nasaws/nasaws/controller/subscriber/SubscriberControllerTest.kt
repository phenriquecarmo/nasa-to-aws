package com.nasaws.nasaws.controller.subscriber

import com.nasaws.nasaws.service.subscriber.SubscriberService
import com.nasaws.nasaws.dtos.subscriber.SubscriberRequest
import com.nasaws.nasaws.models.Subscriber
import org.junit.jupiter.api.Test
import org.mockito.BDDMockito.given
import org.mockito.Mockito.doNothing
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.delete
import org.springframework.test.web.servlet.post
import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import java.time.LocalDateTime

@WebMvcTest(SubscriberController::class)
class SubscriberControllerTest {

    @Autowired
    lateinit var mockMvc: MockMvc

    @MockBean
    lateinit var subscriberService: SubscriberService

    private val objectMapper = jacksonObjectMapper()

    val subscriberRequest = SubscriberRequest(
        email = "email@test.com"
    )

    val subscriber = Subscriber(
        id = 1L,
        email = "email@test.com",
        createdAt = LocalDateTime.now(),
        unsubscribedAt = LocalDateTime.now(),
        isActive = true
    )

    @Test
    fun `check subscription returns ok status`() {
        val request = subscriberRequest
        val subscriber = subscriber
        given(subscriberService.subscribeToMailingList(request)).willReturn(subscriber)

        mockMvc.post("/api/v1/nasaws-mailing/subscribe") {
            contentType = MediaType.APPLICATION_JSON
            content = objectMapper.writeValueAsString(request)
        }.andExpect {
            status { isOk() }
        }
    }

    @Test
    fun `check subscription deactivation returns no content status`() {
        doNothing().`when`(subscriberService).deactivateMailingSubscription("test@example.com")

        mockMvc.delete("/api/v1/nasaws-mailing/unsubscribe") {
            param("email", "test@example.com")
        }.andExpect {
            status { isNoContent() }
        }
    }

    @Test
    fun `check delete subscription returns no content status`() {
        doNothing().`when`(subscriberService).deleteMailingSubscription("test@example.com")

        mockMvc.delete("/api/v1/nasaws-mailing/delete-subscription") {
            param("email", "test@example.com")
        }.andExpect {
            status { isNoContent() }
        }
    }
}