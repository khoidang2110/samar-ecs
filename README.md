TRIỂN KHAI CI/CD VỚI 2 SERVER (CI SERVER + DEPLOY SERVER)

Ở video trước mình đã hướng dẫn triển khai CI/CD trên 1 server bằng GitHub Actions.
Tuy nhiên, triển khai trên một VPS sẽ gặp một vấn đề quan trọng:

Khi build dự án, quá trình build luôn cần sử dụng nhiều tài nguyên CPU và RAM.
Ví dụ:
- Bạn đang chạy nhiều service (nhiều trang FE, nhiều API).
- Khi CI/CD chạy build ngay trên cùng server đó, CPU dễ bị full tải.
- Hệ quả: các trang web, API khác đang chạy sẽ bị chậm, bị lag hoặc timeout.

Vì vậy, trong video này mình triển khai CI/CD với 2 server để tách biệt:
- CI Server (Server 1): thực hiện build - tạo image - push lên Docker Hub.
- Deploy Server (Server 2): thực hiện pull image và deploy.

Nhờ tách biệt, server deploy sẽ rất nhẹ, chỉ pull image mới và khởi động container.
Các service đang chạy sẽ ít bị ảnh hưởng nhất.

----------------------------------------------------------------------
1. Chuẩn bị source code và tạo repo trên GitHub
----------------------------------------------------------------------

Mình đã có source code.
Bây giờ mình tạo repo trên GitHub, sau đó kết nối local với repo bằng:
git init
git remote add origin <repo>
git push

----------------------------------------------------------------------

2. Thêm SSH private key vào GitHub Actions
----------------------------------------------------------------------

Phần tạo SSH key mình đã hướng dẫn ở video CI/CD 1 server, bạn có thể xem lại.

Sau khi có private key, mình thêm vào:
GitHub -> Repo -> Settings -> Secrets -> Actions

----------------------------------------------------------------------

3. Lấy GitHub Actions Runner Token
----------------------------------------------------------------------

Mình vào:
GitHub -> Repo -> Settings -> Actions -> Runners -> New Runner
Chọn Linux để lấy TOKEN.

----------------------------------------------------------------------

4. Triển khai Runner trên Server 1 (CI server - andy-outside)
----------------------------------------------------------------------

Trên server 1 mình chạy Docker Compose để tạo self-hosted runner.
File docker-compose.yml mình đã để sẵn trong repo.

Bạn có thể tạo bao nhiêu runner cũng được, mỗi runner xử lý một job riêng.

Mình tạo file .env và thêm token runner vào:
RUNNER_TOKEN=xxxxxx

Sau đó chạy:
docker compose up -d

Runner bắt đầu khởi động và kết nối với GitHub.

----------------------------------------------------------------------

5. Kiểm tra Runner đã kết nối thành công
----------------------------------------------------------------------

Vào GitHub -> Runners -> thấy runner trạng thái Active là OK.

----------------------------------------------------------------------

6. Login Docker Hub trên cả 2 server
----------------------------------------------------------------------

Bạn phải login Docker Hub trên cả CI server và Deploy server:
docker login -u khoidang2110

Sau đó nhập PAT (Personal Access Token), không phải mật khẩu.
PAT có dạng:
dckr_pat_AAAAAAAAAAAAAAAAAAA

----------------------------------------------------------------------

7. Quy trình build CI và deploy CD chạy thử
----------------------------------------------------------------------

Giờ mình push code mới lên GitHub.
GitHub Action sẽ trigger dựa vào các tags mà mình cấu hình.
Action Runner sẽ thực hiện build image → tag → push lên Docker Hub.

Sau đó Deploy Server sẽ pull image mới và deploy tự động.

----------------------------------------------------------------------

8. Lưu ý về tag image
----------------------------------------------------------------------

Tag rất quan trọng để phân biệt image.
Bạn có thể thêm label theo tên dự án, ví dụ:
samar, api, admin, fe, v.v.

----------------------------------------------------------------------

9. Kiểm tra CPU load để thấy sự khác biệt
----------------------------------------------------------------------

Mình chạy CI/CD để bạn xem mức sử dụng CPU.

Với dự án demo nhẹ → CPU tăng không đáng kể.
Nhưng với dự án nặng hoặc microservice, build sẽ rất nặng.

Nếu build chung server deploy:
- CPU load cao
- API lag ngay lập tức
- người dùng truy cập vào web sẽ bị ảnh hưởng

Khi tách ra:
- CI server chịu toàn bộ phần build
- Deploy server chỉ nhận image mới và chạy lên → cực nhẹ

----------------------------------------------------------------------

10. So sánh thời gian build 1 server vs 2 server
----------------------------------------------------------------------

Ví dụ build static site:

Server build + deploy chung 1 máy:
~ 24 giây

Dùng 2 server:
~ 1 phút 38 giây
(vì phải push rồi pull image)

Nhưng ở trường hợp dự án nặng thì:

Ví dụ Docusaurus nặng:
- Build trên 1 server: gần 11 phút
- Tách CI server riêng: còn 5 phút

Ví dụ microservice build nhiều service:
- 1 runner (1 server): 13 phút
- 3 runner song song: còn gần 6 phút

Tốc độ tăng gấp đôi hoặc hơn.

----------------------------------------------------------------------

11. Tổng kết
----------------------------------------------------------------------

Việc build chung server deploy có thể nhanh hơn ở dự án nhỏ vì không phải push/pull image.
Nhưng ở hệ thống phức tạp hoặc dự án build nặng, việc tách CI server riêng:
- tăng tốc độ build
- giảm ảnh hưởng đến web đang chạy
- dễ scale, dễ nâng cấp tài nguyên build
- có thể chạy nhiều runner song song để tăng tốc CI

Hy vọng video này hữu ích đối với bạn.
