package bit.naver.entity;

import lombok.Data;

import javax.validation.constraints.*;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZonedDateTime;

@Data
public class Users implements Serializable {

    private Long userIdx;


    @NotBlank(message = "아이디는 필수 입력 값입니다.")
    @Size(min = 4, max = 12, message = "아이디는 4~12자 사이여야 합니다.")
    private String username;

    @NotBlank(message = "비밀번호는 필수 입력 값입니다.")
    @Size(min = 8, max = 16, message = "비밀번호는 8~16자 사이여야 합니다.")
    private String password;

    @NotBlank(message = "이메일은 필수 입력 값입니다.")
    @Email(message = "올바른 이메일 형식이 아닙니다.")
    private String email;

    @NotBlank(message = "이름은 필수 입력 값입니다.")
    private String name;

    @NotNull(message = "생년월일은 필수 입력 값입니다.")
    @PastOrPresent(message = "생년월일은 오늘 이전의 날짜여야 합니다.")
    private LocalDate birthdate;

    private String profileImage = "기본이미지.gif";
    private Boolean enabled;
    private Long gradeIdx;
    private String provider;
    private Double latitude;
    private Double longitude;

    @NotBlank(message = "성별은 필수 입력 값입니다.")
    private String gender; // String 타입 유지

    private Boolean socialLogin = false;
//    private String socialLogin; // 소셜 로그인 방식 ("KAKAO" 또는 "GOOGLE" 등)

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public enum Gender { // Gender 열거형 유지
        M, F, OTHER
    }

}
